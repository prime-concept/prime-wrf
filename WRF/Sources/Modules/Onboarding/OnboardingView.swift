import UIKit

protocol OnboardingViewDelegate: AnyObject {
    func onboardingViewDidRequestNextPage()
    func onboardingViewDidRequestDismiss()
    func onboardingViewDidRequestSignUp()
    func onboardingViewDidRequestNotificationPermission()
    func onboardingViewDidRequestLocationPermission()
}

extension OnboardingView {
    struct Appearance {
        let indicatorSelectedColor = UIColor.white
        let indicatorDefaultColor = UIColor.white.withAlphaComponent(0.5)
    }

    enum Constants {
        static var pageCount = 3
        static var animationDuration = 0.5
    }
}

final class OnboardingView: UIView {
    let appearance: Appearance

    weak var delegate: OnboardingViewDelegate?

    private lazy var notificationStepView: OnboardingNotificationStepView = {
        let step = OnboardingNotificationStepView()
        step.delegate = self.delegate
        return step
    }()

    private lazy var geolocationStepView: OnboardingGeolocationStepView = {
        let step = OnboardingGeolocationStepView()
        step.delegate = self.delegate
        return step
    }()

    private lazy var signInStepView: OnboardingSignInStepView = {
        let step = OnboardingSignInStepView()
        step.delegate = self.delegate
        return step
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.numberOfPages = Constants.pageCount
        pageControl.currentPageIndicatorTintColor = self.appearance.indicatorSelectedColor
        pageControl.pageIndicatorTintColor = self.appearance.indicatorDefaultColor
        return pageControl
    }()

    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.delegate = self
        scroll.bounces = false
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.addOnboardingPages()
    }

    // MARK: - Public API

    func moveToNextPage() {
        let nextPage = Int(self.scrollView.contentOffset.x / self.scrollView.frame.width) + 1
        self.pageControl.currentPage = nextPage
        UIView.animate(withDuration: Constants.animationDuration) {
            self.scrollView.contentOffset.x = CGFloat(nextPage) * self.scrollView.frame.width
            self.scrollView.layoutIfNeeded()
        }
    }

    func disableNotificationButton() {
        self.notificationStepView.isNotificationButtonEnabled = false
    }

    func disableLocationButton() {
        self.geolocationStepView.isGeolocationButtonEnabled = false
    }

    // MARK: - Private api

    private func addOnboardingPages() {
        self.scrollView.subviews.forEach { $0.removeFromSuperview() }

        let scrollWidth = self.scrollView.frame.width
        let scrollHeight = self.scrollView.frame.height

        self.scrollView.contentSize =
            CGSize(width: scrollWidth * CGFloat(Constants.pageCount), height: scrollHeight)

        [self.notificationStepView, self.geolocationStepView, self.signInStepView].enumerated()
            .forEach { (index: Int, step: UIView) in
                step.frame.origin.x = CGFloat(index) * scrollWidth
                step.frame.size = self.scrollView.frame.size
                self.scrollView.addSubview(step)
            }
    }
}

extension OnboardingView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.scrollView)
        self.addSubview(self.pageControl)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottomMargin)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
}

extension OnboardingView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        self.pageControl.currentPage = page
    }
}
