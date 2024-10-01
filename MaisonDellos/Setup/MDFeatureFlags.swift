import PrimeGuideCore

struct MDFeatureFlags: FeatureFlagsProtocol {
    let onboarding: any OnboardingFeatureFlags = Onboarding()
    let appSetup: any AppSetupFeatureFlags = AppSetup()
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

// Some of the following values were copied from WRF
// TODO: Replace with production values

extension MDFeatureFlags {
    
    struct Onboarding: OnboardingFeatureFlags {
        let labelInsetTop: CGFloat = 24
        let buttonsInsetBottom: CGFloat = 30
        let needsCenteredLogo = true
        var logoSize = CGSize(width: 138, height: 44)
    }
    
    struct AppSetup: AppSetupFeatureFlags {
        let navigationMode = AppNavigationMode.homeScreen
        let needsTransparentNavigationBar = true
        let isMaisonDellosTarget = true
    }
    
    struct TabBar: TabBarFeatureFlags {
        let shouldUseStaticTitle = false
        let shouldUseUnselectedColor = false
    }
    
    struct Loyalty: LoyaltyFeatureFlags {
        let shouldUseCardImage = false
        let showsPersonifiedFeatures = true
    }
    
    struct Profile: ProfileFeatureFlags {
        let shouldOpenDocumentsInSafari = true
        let shouldDisplayEventCarousel = true
        let scanButtonHidden = true
        let shouldShowPartners = false
        var shouldShowDeliveries = false
        let shouldUpdateActiveBookingsCount = false
    }
    
    struct Map: MapFeatureFlags {
        let showEventsCarousel = true
        let showMapSearch = true
        let showVISALogo = false
        let showRestaurantLogo = true
    }
    
    struct Searching: SearchingFeatureFlags {
        let showDelivery = false
        let showCalendar = false
        let halfPosition = false
        let showHomeSearchBar = true
        let showEmptyStateViewOnTop = true
        let showTagsForRestaurants = true
        let useEventItemSmallImageView = true
    }
    
	struct Events: EventsFeatureFlags {
		let eventCellSize = CGSize(width: 235, height: 168)
        let numberOfVisibleLinesInDescription = 8
	}

	struct Favorites: FavoritesFeatureFlags {
		let favoritesViewHeight: CGFloat = 168
	}

    struct Auth: AuthFeatureFlags {
        let logoSize = CGSize(width: 181, height: 58)
        let shouldUseDarkLogo = false
    }

    struct Restaurants: RestaurantsFeatureFlags {
        let shouldShowPrice = false
    }
}
