import PrimeGuideCore

struct FeatureFlags: FeatureFlagsProtocol {
    let onboarding: any OnboardingFeatureFlags = Onboarding()
    let appSetup: any AppSetupFeatureFlags  = AppSetup()
    let tabBar: any TabBarFeatureFlags = TabBar()
    let loyalty: any LoyaltyFeatureFlags = Loyalty()
    let profile: any ProfileFeatureFlags = Profile()
    let map: any MapFeatureFlags = Map()
    let events: any EventsFeatureFlags = Events()
    let favorites: any FavoritesFeatureFlags = Favorites()
    let searching: any SearchingFeatureFlags = Searching()
    let auth: any AuthFeatureFlags = Auth()
    let restaurants: any RestaurantsFeatureFlags = Restaurants()
}

extension FeatureFlags {
    
    struct Onboarding: OnboardingFeatureFlags {
        let labelInsetTop: CGFloat = 30
        let buttonsInsetBottom: CGFloat = 35
        let needsCenteredLogo = false
        var logoSize = CGSize(width: 73, height: 20)
    }
    
    struct AppSetup: AppSetupFeatureFlags {
        let navigationMode = AppNavigationMode.tabbed
        let needsTransparentNavigationBar = false
        let isMaisonDellosTarget = false
    }
    
    struct TabBar: TabBarFeatureFlags {
        let shouldUseStaticTitle = false
        let shouldUseUnselectedColor = false
    }
    
    struct Loyalty: LoyaltyFeatureFlags {
        let shouldUseCardImage = true
        let showsPersonifiedFeatures = true
    }
    
    struct Profile: ProfileFeatureFlags {
        let shouldDisplayEventCarousel = false
        let shouldOpenDocumentsInSafari = false
        let scanButtonHidden = true
        let shouldShowPartners = true
        let shouldShowDeliveries = true
        let shouldUpdateActiveBookingsCount = true
    }
    
    struct Map: MapFeatureFlags {
        let showMapSearch = false
        let showEventsCarousel = false
        let showVISALogo = false
        let showRestaurantLogo = false
    }
    
    struct Searching: SearchingFeatureFlags {
        let showDelivery = true
        let showCalendar = true
        let halfPosition = true
        let showHomeSearchBar = false
        let showEmptyStateViewOnTop = false
        let showTagsForRestaurants = false
        let useEventItemSmallImageView = false
    }

	struct Events: EventsFeatureFlags {
		let eventCellSize = CGSize(width: 235, height: 210)
        let numberOfVisibleLinesInDescription = 4
	}

	struct Favorites: FavoritesFeatureFlags {
		let favoritesViewHeight: CGFloat = 210
	}
    
    struct Auth: AuthFeatureFlags {
        let logoSize = CGSize(width: 121, height: 33)
        let shouldUseDarkLogo = true
    }
    struct Restaurants: RestaurantsFeatureFlags {
        let shouldShowPrice = true
    }
}
