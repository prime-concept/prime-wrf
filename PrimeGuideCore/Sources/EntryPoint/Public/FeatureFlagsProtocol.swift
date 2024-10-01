// TODO: Rename to `FeatureFlags` when doing so won’t result in name collision
public protocol FeatureFlagsProtocol {
    var onboarding: any OnboardingFeatureFlags { get }
    var appSetup: any AppSetupFeatureFlags { get }
    var tabBar: any TabBarFeatureFlags { get }
    var loyalty: any LoyaltyFeatureFlags { get }
    var profile: any ProfileFeatureFlags { get }
    var map: any MapFeatureFlags { get }
    var events: any EventsFeatureFlags { get }
    var favorites: any FavoritesFeatureFlags { get }
    var searching: any SearchingFeatureFlags { get }
    var auth: any AuthFeatureFlags { get }
    var restaurants: any RestaurantsFeatureFlags { get }
}

public protocol OnboardingFeatureFlags {
    var labelInsetTop: CGFloat { get }
    var buttonsInsetBottom: CGFloat { get }
    var needsCenteredLogo: Bool { get }
    var logoSize: CGSize { get }
}

public protocol AppSetupFeatureFlags {
    var navigationMode: AppNavigationMode { get }
    var needsTransparentNavigationBar: Bool { get }
    var isMaisonDellosTarget: Bool { get }
}

public enum AppNavigationMode {
    case tabbed
    case homeScreen
}

public protocol TabBarFeatureFlags {
    var shouldUseStaticTitle: Bool { get }
    var shouldUseUnselectedColor: Bool { get }
}

public protocol LoyaltyFeatureFlags {
    var shouldUseCardImage: Bool { get }
    var showsPersonifiedFeatures: Bool { get }
}

public protocol ProfileFeatureFlags {
    var scanButtonHidden: Bool { get }
    var shouldDisplayEventCarousel: Bool { get }
    var shouldShowPartners: Bool { get }
    var shouldShowDeliveries: Bool { get }
    var shouldOpenDocumentsInSafari: Bool { get }
    var shouldUpdateActiveBookingsCount: Bool { get }
}

public protocol MapFeatureFlags {
    var showVISALogo: Bool { get }
    var showEventsCarousel: Bool { get }
    var showMapSearch: Bool { get }
    var showRestaurantLogo: Bool { get }
}

public protocol EventsFeatureFlags {
	var eventCellSize: CGSize { get }
    var numberOfVisibleLinesInDescription: Int { get }
}

public protocol FavoritesFeatureFlags {
    var favoritesViewHeight: CGFloat { get }
}

public protocol SearchingFeatureFlags {
    var showDelivery: Bool { get }
    var showCalendar: Bool { get }
    var halfPosition: Bool { get }
    var showHomeSearchBar: Bool { get }
    var showEmptyStateViewOnTop: Bool { get }
    var showTagsForRestaurants: Bool { get }
    var useEventItemSmallImageView: Bool { get }
}

public protocol AuthFeatureFlags {
    var logoSize: CGSize { get }
    var shouldUseDarkLogo: Bool { get }
}

public protocol RestaurantsFeatureFlags {
    var shouldShowPrice: Bool { get }
}
