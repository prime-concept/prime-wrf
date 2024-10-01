import PromiseKit
import UIKit

protocol NotificationsPresenterProtocol {
    func loadNotifications()
}

final class NotificationsPresenter: NotificationsPresenterProtocol {
    weak var viewController: NotificationsViewControllerProtocol?

    private let notificationEndpoint: PrimePassNotifyEndpointProtocol
    private let authService: AuthServiceProtocol
    private let notificationPersistenceService: NotificationPersistenceServiceProtocol

    private let messageTimeFormatter: DateFormatter
    private let sectionDateFormatter: DateFormatter
    private let calendar: Calendar

    init(
        notificationEndpoint: PrimePassNotifyEndpointProtocol,
        authService: AuthServiceProtocol,
        notificationPersistenceService: NotificationPersistenceServiceProtocol
    ) {
        self.notificationEndpoint = notificationEndpoint
        self.authService = authService
        self.notificationPersistenceService = notificationPersistenceService

        self.messageTimeFormatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        self.messageTimeFormatter.dateFormat = "HH:mm"

        self.sectionDateFormatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        self.sectionDateFormatter.dateFormat = "dd MMMM"

        self.calendar = FormatterHelper.makeCorrectLocaleCalendar()
    }

    // MARK: - Public API

    func loadNotifications() {
        guard let userID = self.authService.authorizationData?.userID else {
            return
        }
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.notificationPersistenceService.retrieve()
        }.done { notifications in
            let model = self.makeViewModel(from: notifications)
            self.viewController?.set(notifications: model)
        }.then(on: queue) { _ in
            self.notificationEndpoint.retrieve(userID: userID).result
        }.done(on: queue) { response in
            guard let notifications = response.data else {
                return
            }
            self.notificationPersistenceService.save(notifications: notifications)
            DispatchQueue.main.async {
                let model = self.makeViewModel(from: notifications)
                self.viewController?.set(notifications: model)
            }
        }.catch { error in
            print("notification presenter: error fetching notifications \(error.localizedDescription)")
        }
    }

    // MARK: - Private API

    private func makeMessageTimeText(date: Date) -> String {
        if self.messageWasSentNow(date: date) {
            return "Только что"
        }
        return self.messageTimeFormatter.string(from: date)
    }

    private func makeSectionText(date: Date) -> String {
        if self.calendar.isDateInToday(date) {
            return "Сегодня"
        }
        if self.calendar.isDateInYesterday(date) {
            return "Вчера"
        }
        return self.sectionDateFormatter.string(from: date)
    }

    private func messageWasSentNow(date: Date) -> Bool {
        let currentDate = Date()
        return (currentDate.timeIntervalSince1970 - date.timeIntervalSince1970) <= 60
    }

    private func makeViewModel(from notifications: [PrimePassNotification]) -> [NotificationSectionViewModel] {
        let grouped = Dictionary(grouping: notifications) { notification -> Date in
            let components = self.calendar.dateComponents([.year, .month, .day], from: notification.time)
            return self.calendar.date(from: components) ?? Date()
        }.sorted { $0.key > $1.key }

        return grouped.map { (date, notifications) in
            NotificationSectionViewModel(
                name: self.makeSectionText(date: date),
                notifications: notifications.map { self.makeViewModel(from: $0) }
            )
        }
    }

    private func makeViewModel(from notification: PrimePassNotification) -> NotificationViewModel {
        return NotificationViewModel(
            id: notification.id,
            message: notification.message,
            messageTime: self.makeMessageTimeText(date: notification.time)
        )
    }
}
