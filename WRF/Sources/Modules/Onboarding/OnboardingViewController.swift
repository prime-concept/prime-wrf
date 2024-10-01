import CoreLocation
import UIKit
import UserNotifications

final class OnboardingViewController: UIViewController {
    private lazy var onboardingView = self.view as? OnboardingView

    private var askedOnceForNotificationPermission = false

    private var notificationPermissionAcquired = false
    private var locationPermissionAcquired = false

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: – Life Cycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = OnboardingView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.onboardingView?.delegate = self
        self.modalPresentationCapturesStatusBarAppearance = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private API

    @objc
    private func didEnterForeground() {
        if !self.notificationPermissionAcquired {
            self.recheckNotificationSettings()
        }
        if !self.locationPermissionAcquired {
            self.recheckLocationSettings()
        }
    }
}

// MARK: – OnboardingViewDelegate

extension OnboardingViewController: OnboardingViewDelegate {
    func onboardingViewDidRequestDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    func onboardingViewDidRequestNotificationPermission() {
        let dialog = UIAlertController(
            title: "Включить уведомления",
            message: "Напомним о брони, расскажем о вечеринках в любимых ресторанах",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let notificationAction = UIAlertAction(title: "Включить", style: .default) { _ in
            self.askForNotifications()
        }
        dialog.addAction(cancelAction)
        dialog.addAction(notificationAction)
        dialog.popoverPresentationController?.sourceView = self.view
        self.present(dialog, animated: true)
    }

    func onboardingViewDidRequestLocationPermission() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationPermissionAcquired = true

            self.onboardingView?.moveToNextPage()
            self.onboardingView?.disableLocationButton()
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
        default:
            self.openSettingsDialog(
                title: "Запрос на геолокацию",
                message: "Изменить параметры геолокации в настройках"
            )
        }
    }

    func onboardingViewDidRequestNextPage() {
        self.onboardingView?.moveToNextPage()
    }

    func onboardingViewDidRequestSignUp() {
        let viewControllerToPresent = AuthAssembly(page: .signUp).makeModule()
        viewControllerToPresent.modalPresentationStyle = .fullScreen

        let presentingViewController = self.presentingViewController
        self.dismiss(animated: true) {
            presentingViewController?.present(viewControllerToPresent, animated: true)
        }
    }

    // MARK: - Private API

    private func recheckNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                self.notificationPermissionAcquired = true

                DispatchQueue.main.async {
                    self.onboardingView?.disableNotificationButton()
                }
            }
        }
    }

    private func recheckLocationSettings() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationPermissionAcquired = true

            DispatchQueue.main.async {
                self.onboardingView?.disableLocationButton()
            }
        default:
            break
        }
    }

    private func askForNotifications() {
        let notificationOptions: UNAuthorizationOptions = [
            UNAuthorizationOptions.badge,
            UNAuthorizationOptions.alert,
            UNAuthorizationOptions.sound
        ]
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: notificationOptions) { success, _ in
            DispatchQueue.main.async {
                if success {
                    self.notificationPermissionAcquired = true

                    self.onboardingView?.moveToNextPage()
                    self.onboardingView?.disableNotificationButton()
                } else {
                    guard self.askedOnceForNotificationPermission else {
                        self.askedOnceForNotificationPermission = true
                        return
                    }
                    self.openSettingsDialog(
                        title: "Запрос на уведомления",
                        message: "Изменить параметры уведомлений в настройках"
                    )
                }
            }
        }
    }

    private func openSettingsDialog(title: String, message: String?) {
        let dialog = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let settingsAction = UIAlertAction(title: "Перейти", style: .default) { _ in
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=\(bundleId)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        dialog.addAction(cancelAction)
        dialog.addAction(settingsAction)
        dialog.popoverPresentationController?.sourceView = self.view
        self.present(dialog, animated: true)
    }
}

// MARK: – CLLocationManagerDelegate

extension OnboardingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if !self.locationPermissionAcquired {
                self.onboardingView?.moveToNextPage()
            }
            self.onboardingView?.disableLocationButton()

            NotificationCenter.default.post(name: .locationPermissionAcquired, object: nil)
        }
    }
}
