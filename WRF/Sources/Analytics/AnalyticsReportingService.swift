
import Foundation

protocol AnalyticsReportingServiceProtocol {
    func didTapOnBookingButton(restaurantId: String, name: String)
    func didBookRestaurantSuccessfully(restaurantId: String, name: String)
    func didCallRestaurantForInfo(restaurantId: String, name: String, phoneNumber: String)
    func didТapOnNewsFromEvents(eventId: String)
    func didTransitionToProfile()
    func didTransitionToHistory()
    func didTransitionToFavorites()
    func didTransitionToProfileSettings()
    func didTransitionToRestaurantCard(id: String, name: String)
    func didTapOnShareButton(restaurantId: String)
    func didUpdateFavoriteState(restaurantId: String, isFavorite: Bool)
    func didTapOnMenuButton(restaurantId: String)
    func didTapOnDeliveryButton(restaurantId: String)
    func didTapOnPhotoGallery(restaurantId: String)
    func didTapOnEventsItem(restaurantId: String, eventId: String)
    func didScrollRestaurantReviews(restaurantId: String)
    func didTapOpenRoute(restaurantId: String)
    func didTapOnOpenWebpage(restaurantId: String)
    func didCallRestaurantForBooking(restaurantId: String, name: String, phoneNumber: String)
    func didTransitionToNotifications()
    func didTransitionToFilters()
    func didShowUserLocation()
    func didFilterByTopTag(id: String)
    func didActivateSearchMode()
    func didTapOnSearchCategory(item: String)
    func didTapOnLoyaltyCard()
    func didTapOnCertificates()
    func didTapOnCertificatesTab(name: String)
    func didSelectCertificate(id: String, tabName: String)
    func didPurchaseCertificate(id: String)
    func didMoveMapView()
    func didSelectTomorrowForBooking()
    func didSelectCalendarForBooking()
    func didTapOnBookingFromHistory(id: String)
    func didTapOnDeliveryFromHistory()
    func didFilterByAdvancedFilter(items: String)
}

final class AnalyticsReportingService: AnalyticsReportingServiceProtocol {
    static let shared = AnalyticsReportingService()
    
    func didTapOnBookingButton(restaurantId: String, name: String) {
        AnalyticsEvents.General.didTapOnBookingButton(restaurantId: restaurantId, name: name).send()
    }
    
    func didBookRestaurantSuccessfully(restaurantId: String, name: String) {
        AnalyticsEvents.General.didBookRestaurantSuccessfully(restaurantId: restaurantId, name: name).send()
    }
    
    func didCallRestaurantForInfo(restaurantId: String,
                                  name: String,
                                  phoneNumber: String) {
        AnalyticsEvents.General.didCallRestaurantForInfo(restaurantId: restaurantId,
                                                         name: name,
                                                         phoneNumber: phoneNumber).send()
    }
    
    func didТapOnNewsFromEvents(eventId: String) {
        AnalyticsEvents.General.didТapOnNewsFromEvents(eventId: eventId).send()
    }
    
    func didTransitionToProfile() {
        AnalyticsEvents.General.didTransitionToProfile.send()
    }
    
    func didTransitionToHistory() {
        AnalyticsEvents.General.didTransitionToHistory.send()
    }
    
    func didTransitionToFavorites() {
        AnalyticsEvents.General.didTransitionToFavorites.send()
    }
    
    func didTransitionToProfileSettings() {
        AnalyticsEvents.General.didTransitionToProfileSettings.send()
    }
    
    func didTransitionToRestaurantCard(id: String, name: String) {
        AnalyticsEvents.General.didTransitionToRestaurantCard(id: id, name: name).send()
    }
    
    func didTapOnShareButton(restaurantId: String) {
        AnalyticsEvents.General.didTapOnShareButton(restaurantId: restaurantId).send()
    }
    
    func didUpdateFavoriteState(restaurantId: String, isFavorite: Bool) {
        AnalyticsEvents.General.didUpdateFavoriteState(restaurantId: restaurantId,
                                                       isFavorite: isFavorite).send()
    }
    
    func didTapOnMenuButton(restaurantId: String) {
        AnalyticsEvents.General.didTapOnMenuButton(restaurantId: restaurantId).send()
    }
    
    func didTapOnDeliveryButton(restaurantId: String) {
        AnalyticsEvents.General.didTapOnDeliveryButton(restaurantId: restaurantId).send()
    }
    
    func didTapOnPhotoGallery(restaurantId: String) {
        AnalyticsEvents.General.didTapOnPhotoGallery(restaurantId: restaurantId).send()
    }
    
    func didTapOnEventsItem(restaurantId: String, eventId: String) {
        AnalyticsEvents.General.didTapOnEventsItem(restaurantId: restaurantId, eventId: eventId).send()
    }
    
    func didScrollRestaurantReviews(restaurantId: String) {
        AnalyticsEvents.General.didScrollRestaurantReviews(restaurantId: restaurantId).send()
    }
    
    func didTapOpenRoute(restaurantId: String) {
        AnalyticsEvents.General.didTapOpenRoute(restaurantId: restaurantId).send()
    }
    
    func didTapOnOpenWebpage(restaurantId: String) {
        AnalyticsEvents.General.didTapOnOpenWebpage(restaurantId: restaurantId).send()
    }
    
    func didCallRestaurantForBooking(restaurantId: String, name: String, phoneNumber: String) {
        AnalyticsEvents.General.didCallRestaurantForBooking(restaurantId: restaurantId,
                                                            name: name,
                                                            phoneNumber: phoneNumber).send()
    }
    
    func didTransitionToNotifications() {
        AnalyticsEvents.General.didTransitionToNotifications.send()
    }
    
    func didTransitionToFilters() {
        AnalyticsEvents.General.didTransitionToFilters.send()
    }
    
    func didShowUserLocation() {
        AnalyticsEvents.General.didShowUserLocation.send()
    }
    
    func didFilterByTopTag(id: String) {
        AnalyticsEvents.General.didFilterByTopTag(id: id).send()
    }
    
    func didActivateSearchMode() {
        AnalyticsEvents.General.didActivateSearchMode.send()
    }
    
    func didTapOnSearchCategory(item: String) {
        AnalyticsEvents.General.didTapOnSearchCategory(item: item).send()
    }
    
    func didTapOnLoyaltyCard() {
        AnalyticsEvents.General.didTapOnLoyaltyCard.send()
    }
    
    func didTapOnCertificates() {
        AnalyticsEvents.General.didTapOnCertificates.send()
    }
    
    func didTapOnCertificatesTab(name: String) {
        AnalyticsEvents.General.didTapOnCertificatesTab(name: name).send()
    }
    
    func didSelectCertificate(id: String, tabName: String) {
        AnalyticsEvents.General.didSelectCertificate(id: id, tabName: tabName).send()
    }
    
    func didPurchaseCertificate(id: String) {
        AnalyticsEvents.General.didPurchaseCertificate(id: id).send()
    }
    
    func didMoveMapView() {
        AnalyticsEvents.General.didMoveMapView.send()
    }
    
    func didSelectTomorrowForBooking() {
        AnalyticsEvents.General.didSelectTomorrowForBooking.send()
    }
    
    func didSelectCalendarForBooking() {
        AnalyticsEvents.General.didSelectCalendarForBooking.send()
    }
    
    func didTapOnBookingFromHistory(id: String)  {
        AnalyticsEvents.General.didTapOnBookingFromHistory(id: id).send()
    }
    
    func didTapOnDeliveryFromHistory() {
        AnalyticsEvents.General.didTapOnDeliveryFromHistory.send()
    }
    
    func didFilterByAdvancedFilter(items: String) {
        AnalyticsEvents.General.didFilterByAdvancedFilter(items: items).send()
    }
}
