
import Foundation

final class AnalyticsEvent: AnalyticsReportable {
    @discardableResult
    func send(
        _ provider: AnalyticsReporterProvider = .yandexMetrica
    ) -> Self {
        AnalyticsReporter.reportEvent(name, parameters: parameters, provider: provider)
        return self
    }
    
    var name: String
    var parameters: [String: Any]
    
    init(name: String, parameters: [String: Any] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

struct AnalyticsEvents {
    struct General {
        static var didTransitionToProfile = AnalyticsEvent(name: "Did Transition To Profile")
        static var didTransitionToHistory = AnalyticsEvent(name: "Did Transition To History")
        static var didTransitionToFavorites = AnalyticsEvent(name: "Did Transition To Favorites")
        static var didTransitionToProfileSettings = AnalyticsEvent(name: "Did Transition To Profile Settings")
        static var didTransitionToNotifications = AnalyticsEvent(name: "Did Transition To Notifications")
        static var didTransitionToFilters = AnalyticsEvent(name: "Did Transition To Filters")
        static var didShowUserLocation = AnalyticsEvent(name: "Did Show User Location")
        static var didTapOnLoyaltyCard = AnalyticsEvent(name: "Did Tap On Loyalty Card")
        static var didTapOnCertificates = AnalyticsEvent(name: "Did Tap On Certificates")
        static var didActivateSearchMode = AnalyticsEvent(name: "Did Activate Search Mode")
        static var didMoveMapView = AnalyticsEvent(name: "Did Move Map View")
        static var didSelectTomorrowForBooking = AnalyticsEvent(name:"Did Select Tomorrow For Booking")
        static var didSelectCalendarForBooking = AnalyticsEvent(name:"Did Select Calendar For Booking")
        static var didTapOnDeliveryFromHistory = AnalyticsEvent(name:"Did Tap On Delivery From History")
        
        static func didCallRestaurantForInfo(restaurantId: String,
                                             name: String,
                                             phoneNumber: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Call Restaurant For Info",
                parameters: ["restaurantId": restaurantId,
                             "name": name,
                             "phoneNumber": phoneNumber]
            )
        }
        
        static func didTapOnBookingButton(restaurantId: String, name: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Tap On Booking Button",
                parameters: ["restaurantId": restaurantId, "name": name]
            )
        }
        
        static func didBookRestaurantSuccessfully(restaurantId: String, name: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Book Restaurant Successfully",
                parameters: ["restaurantId": restaurantId, "name": name]
            )
        }
        
        static func didТapOnNewsFromEvents(eventId: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Тap On News From Events",
                parameters: ["id": eventId]
            )
        }
        
        static func didTransitionToRestaurantCard(id: String, name: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Transition To Restaurant Card",
                parameters: ["id": id, "name": name]
            )
        }
        
        static func didTapOnShareButton(restaurantId: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Tap On Share Button",
                parameters: ["restaurantId": restaurantId]
            )
        }
        
        static func didUpdateFavoriteState(restaurantId: String, isFavorite: Bool) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Update Favorite State",
                parameters: ["restaurantId": restaurantId,
                             "isFavorite": isFavorite]
            )
        }
        
        static func didTapOnMenuButton(restaurantId: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Tap On Menu Button",
                parameters: ["restaurantId": restaurantId]
            )
        }
        
        static func didTapOnDeliveryButton(restaurantId: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Tap On Delivery Button",
                parameters: ["restaurantId": restaurantId]
            )
        }
        
        static func didTapOnPhotoGallery(restaurantId: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Tap On Photo Gallery",
                parameters: ["restaurantId": restaurantId]
            )
        }
        
        static func didTapOnEventsItem(restaurantId: String, eventId: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Tap On Events Item",
                parameters: ["restaurantId": restaurantId,
                             "eventId": eventId]
            )
        }
        
        static func didScrollRestaurantReviews(restaurantId: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Scroll Restaurant Reviews",
                parameters: ["restaurantId": restaurantId]
            )
        }
        
        static func didTapOpenRoute(restaurantId: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Tap Open Route",
                parameters: ["restaurantId": restaurantId]
            )
        }
        
        static func didTapOnOpenWebpage(restaurantId: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Tap On Open Webpage",
                parameters: ["restaurantId": restaurantId]
            )
        }
        
        static func didCallRestaurantForBooking(restaurantId: String,
                                                name: String,
                                                phoneNumber: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Call Restaurant For Booking",
                parameters: ["restaurantId": restaurantId,
                             "name": name,
                             "phoneNumber": phoneNumber]
            )
        }
        
        static func didFilterByTopTag(id: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Select Top Tags",
                parameters: ["id": id]
            )
        }
        
        static func didTapOnSearchCategory(item: String) -> AnalyticsEvent {
            AnalyticsEvent(name: "Did Tap On Search Category",
                           parameters: ["item": item])
        }
        
        static func didTapOnCertificatesTab(name: String) -> AnalyticsEvent {
            AnalyticsEvent(name: "Did Tap On Certificates Tab",
                           parameters: ["name": name])
        }
        
        static func didSelectCertificate(id: String, tabName: String) -> AnalyticsEvent {
            AnalyticsEvent(name: "Did Select Certificate",
                           parameters: ["id": id, "tab": tabName])
        }
        
        static func didPurchaseCertificate(id: String) -> AnalyticsEvent {
            AnalyticsEvent(name: "Did Purchase Certificate",
                           parameters: ["id": id])
        }
        
        static func didTapOnBookingFromHistory(id: String) -> AnalyticsEvent {
            AnalyticsEvent(name: "Did Tap On Booking From History",
                           parameters: ["id": id])
        }
        
        static func didFilterByAdvancedFilter(items: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Did Filter By Advanced Filter",
                parameters: ["items": items]
            )
        }
    }
}
