import Foundation

// 101
enum AvailableGuestSettings {
    static let settings = [
        Setting(title: "Обратная связь", icon: UIImage(named: "settings-feedback"), type: .feedback),
        Setting(title: "О компании", icon: UIImage(named: "settings-about"), type: .about),
        Setting(title: "Контакты", icon: UIImage(named: "settings-contacts"), type: .contactUs),
        Setting(title: "Пользовательское соглашение", icon: UIImage(named: "settings-document"), type: .termsOfUse),
        Setting(title: "О сервисе", icon: UIImage(named: "settings-about"), type: .aboutService),
        Setting(title: "Для партнеров", icon: UIImage(named: "settings-about"), type: .forPartners)
    ]
}
