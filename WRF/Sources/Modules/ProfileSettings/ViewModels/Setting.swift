import UIKit

enum SettingType {
    case profileEdit
    case paymentMethods
    case notifications
    case feedback
    case faq
    case about
    case contactUs
    case loyaltyProgramRules
    case privacyPolicy
    case termsOfUse
    case aboutService
    case forPartners
    case profileDeletion
}

struct Setting {
    let title: String
    var icon: UIImage?
    let type: SettingType
}
