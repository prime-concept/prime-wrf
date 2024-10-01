import UIKit

class Theme: Codable {
    static let shared = Theme()

    
    // Modules/Certificates/List/Views/CertificatesNavigationView.swift
    private(set) var certificatesNavigationViewAppearance = CertificatesNavigationView.Appearance()

    // Modules/Profile/ProfileView.swift
    private(set) var profileViewAppearance = ProfileView.Appearance()

    // Modules/Search/Views/EmptyDataView.swift
    private(set) var emptyDataViewAppearance = EmptyDataView.Appearance()

    // Modules/ProfileSettings/ProfileSettingsView.swift
    private(set) var profileSettingsViewAppearance = ProfileSettingsView.Appearance()

    // Modules/ProfileSettings/Views/SettingsItemView.swift
    private(set) var settingsItemViewAppearance = SettingsItemView.Appearance()

    // Views/Tabman/WRFBarButton.swift
    private(set) var wrfBarButtonAppearance = WRFBarButton.Appearance()
    
    // Modules/Profile/MyCard/Views/CardView.swift
    private(set) var cardViewAppearance = CardView.Appearance()
    
    // Modules/Profile/MyCard/Views/MyCardQRCodeView.swift
    private(set) var myCardQRCodeViewAppearance = MyCardQRCodeView.Appearance()

    // Modules/Profile/MyCard/Views/UserView.swift
    private(set) var userViewAppearance = UserView.Appearance()
    
    //Modules/Profile/MyCard/Views/CardHeaderView/WRF/CardHeaderView.swift
    private(set) var cardHeaderViewAppearance = CardHeaderView.Appearance()

    // Modules/Profile/MyCard/Views/GradientRectangleView.swift
    private(set) var gradientRectangleViewAppearance = GradientRectangleView.Appearance()
    // Modules/BookingInfo/ProfieBookingInfoView.swift
//    private(set) var profieBookingInfoViewAppearance = ProfieBookingInfoView.Appearance()
}

extension Theme {
    func updateFrom(file: String, ofType type: String) {
        if let path = Bundle.main.path(forResource: file, ofType: type),
           let json = try? String(contentsOfFile: path),
           let data = json.data(using: .utf8) {
            self.update(from: data)
        }
    }

    func update(from data: Data) {
        guard let instance = try? JSONDecoder().decode(Theme.self, from: data)
        else {
            return
        }
        
        self.certificatesNavigationViewAppearance = instance.certificatesNavigationViewAppearance
        self.profileViewAppearance = instance.profileViewAppearance
        self.emptyDataViewAppearance = instance.emptyDataViewAppearance
        self.profileSettingsViewAppearance = instance.profileSettingsViewAppearance
        self.settingsItemViewAppearance = instance.settingsItemViewAppearance
        self.wrfBarButtonAppearance = instance.wrfBarButtonAppearance
        self.cardViewAppearance = instance.cardViewAppearance
        self.myCardQRCodeViewAppearance = instance.myCardQRCodeViewAppearance
        self.userViewAppearance = instance.userViewAppearance
        self.cardHeaderViewAppearance = instance.cardHeaderViewAppearance
        self.gradientRectangleViewAppearance = instance.gradientRectangleViewAppearance
        
        NotificationCenter.default.post(.paletteDidChange)
    }

    func appearance<T>() -> T! {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first { $0.value is T }?.value as? T
    }
}
