import Foundation
import UIKit

// WRF
enum AvailableGuestSettings {
    static let settings: [Setting] = {
        var settingArray: [Setting] = [
            Setting(title: "Обратная связь", icon: UIImage(named: "settings-feedback"), type: .feedback),
            Setting(title: "FAQ", icon: UIImage(named: "settings-faq"), type: .faq),
            Setting(title: "О компании", icon: UIImage(named: "settings-about"), type: .about),
            Setting(title: "Правила программы лояльности", icon: UIImage(named: "settings-document"), type: .loyaltyProgramRules),
            Setting(title: "Политика конфиденциальности", icon: UIImage(named: "settings-document"), type: .privacyPolicy),
            Setting(title: "Пользовательское соглашение", icon: UIImage(named: "settings-document"), type: .termsOfUse),
            Setting(title: "О сервисе", icon: UIImage(named: "settings-about"), type: .aboutService),
            Setting(title: "Удалить аккаунт", icon: UIImage(named: "settings-delete"), type: .profileDeletion)
        ]
        if PGCMain.shared.featureFlags.profile.shouldShowPartners {
            settingArray.insert(
                Setting(title: "Для партнеров", icon: UIImage(named: "settings-about"), type: .forPartners),
                at: settingArray.count - 1)
            settingArray.insert(
                Setting(title: "Контакты", icon: UIImage(named: "settings-contacts"), type: .contactUs),
                at: 4)
        }
        return settingArray
    }()
}
