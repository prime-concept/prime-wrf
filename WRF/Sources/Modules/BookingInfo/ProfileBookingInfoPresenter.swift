import CoreLocation
import PromiseKit

protocol ProfileBookingInfoPresenterProtocol {
    func loadBooking()
    func cancelBooking()
}

extension Notification.Name {
	static let didCancelBooking =  Notification.Name("didCancelBooking")
}

final class ProfileBookingInfoPresenter: ProfileBookingInfoPresenterProtocol {
    weak var viewController: ProfileBookingInfoViewControllerProtocol?

    private let booking: HostessBooking
    private let restaurant: Restaurant
    private var assessment: PrimePassAssessment?

    private let feedbackEndpoint: PrimePassFeedbackEndpointProtocol
    private let bookingEndpoint: HostessBookingEndpointProtocol
    private let bookingCancelEndpoint: HostessBookingCancelEndpointProtocol
    private let locationService: LocationServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        booking: HostessBooking,
        restaurant: Restaurant,
        feedbackEndpoint: PrimePassFeedbackEndpointProtocol,
        bookingEndpoint: HostessBookingEndpointProtocol,
        bookingCancelEndpoint: HostessBookingCancelEndpointProtocol,
        locationService: LocationServiceProtocol,
        authService: AuthServiceProtocol
    ) {
        self.booking = booking
        self.restaurant = restaurant
        self.feedbackEndpoint = feedbackEndpoint
        self.bookingEndpoint = bookingEndpoint
        self.bookingCancelEndpoint = bookingCancelEndpoint
        self.locationService = locationService
        self.authService = authService
    }

    // MARK: - Public API

    func loadBooking() {
        self.viewController?.set(
            booking: self.makeViewModel(
                hostessBooking: self.booking,
                restaurant: self.restaurant,
                location: self.locationService.lastLocation?.coordinate,
                assessment: self.assessment
            )
        )

        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            () -> Promise<(PrimePassArrayResponse<PrimePassAssessment>, PrimePassArrayResponse<PrimePassReview>)> in
            let assesment: Promise<PrimePassArrayResponse<PrimePassAssessment>> = self.restaurant.primePassID.isEmpty
                ? .value(PrimePassArrayResponse<PrimePassAssessment>(status: .ok, data: [], error: nil))
                : self.feedbackEndpoint.retrieveAssessment(place: self.restaurant.primePassID).result

            let review: Promise<PrimePassArrayResponse<PrimePassReview>> = self.restaurant.primePassID.isEmpty
                ? .value(PrimePassArrayResponse<PrimePassReview>(status: .ok, data: [], error: nil))
                : self.feedbackEndpoint.retrieveReviews(place: self.restaurant.primePassID).result

            return when(fulfilled: assesment, review)
        }.done { result in
            let (assessmentsResponse, reviewsResponse) = result

            let reviews = reviewsResponse.data ?? []

            self.viewController?.set(
                booking: self.makeViewModel(
                    hostessBooking: self.booking,
                    restaurant: self.restaurant,
                    assessment: assessmentsResponse.data?.first,
                    reviews: reviews
                )
            )

            self.locationService.fetchLocation { result in
                guard case .success(let location) = result else {
                    return
                }

                self.viewController?.set(
                    booking: self.makeViewModel(
                        hostessBooking: self.booking,
                        restaurant: self.restaurant,
                        location: location,
                        assessment: assessmentsResponse.data?.first,
                        reviews: reviews
                    )
                )
            }
        }.catch { error in
            print("booking info presenter: error retrieving assessments \(String(describing: error))")
        }
    }

    func cancelBooking() {
        guard self.authService.isAuthorized else {
            return
        }
        self.viewController?.showLoading()

        DispatchQueue.global(qos: .userInitiated).promise {
            self.bookingCancelEndpoint.cancel(self.booking).result
		}.done { (response: HostessResponse<HostessBookingCancelResponse>) in
			NotificationCenter.default.post(Notification.init(name: .didCancelBooking))
            self.viewController?.showCancelResult(success: response.isSuccessful)
        }.ensure {
            self.viewController?.hideLoading()
        }.catch { error in
            print("booking info presenter: error when cancelling booking \(error.localizedDescription)")
        }
    }

    // MARK: - Private API

    private func makeViewModel(
        hostessBooking: HostessBooking,
        restaurant: Restaurant,
        location: CLLocationCoordinate2D? = nil,
        assessment: PrimePassAssessment?,
        reviews: [PrimePassReview] = []
    ) -> BookingInfoViewModel {
        var rating: Int = 0
        if let assessment = assessment {
            rating = Int(assessment.rating)
        }

        let distanceText: String? = {
            if location != nil,
               let coordinate = restaurant.coordinates?.coordinate,
               let distance = self.locationService.distanceFromLocation(to: coordinate) {
                return FormatterHelper.distanceRepresentation(distanceInMeters: distance)
            }
            return nil
        }()

        let dateFormat = FormatterHelper.makeCorrectLocaleDateFormatter()
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        dateFormat.dateFormat = "d MMM"
        let bookingDate = dateFormat.string(from: self.booking.date)
        dateFormat.dateFormat = "HH:mm"
        let bookingTime = dateFormat.string(from: self.booking.date)

        let guestsText = "\(self.booking.guests) \(Localization.pluralForm(number: self.booking.guests, forms: ["гость", "гостя", "гостей"]))"

        let booking = BookingInfoViewModel.Booking(
            guests: guestsText,
            date: bookingDate,
            time: bookingTime
        )

        let reviewRating: BookingInfoViewModel.ReviewRating? = {
            if !reviews.isEmpty {
                let reviewsRating = Float(reviews.map { $0.assessment }.reduce(0, +) / reviews.count)
                let reviewsCount = reviews.count
                return BookingInfoViewModel.ReviewRating(
                    reviewsRating: reviewsRating,
                    reviewsTotal: reviewsCount
                )
            }
            return nil
        }()

		var isCancellable = [.new, .external, .confirmed].contains(hostessBooking.status)
		isCancellable = isCancellable && ((hostessBooking.deposit ?? 0) <= 0)
		let isMobileOriginated = hostessBooking.type == .order
        let cancelTitle: String = {
            switch hostessBooking.status {
            case .new:
                return "Отменить заявку"
            case .confirmed, .external:
                return "Отменить бронь"
            default:
                return ""
            }
        }()

        var coordninate: (Double, Double)? = nil
        if let coordinates = restaurant.coordinates {
            coordninate = (coordinates.latitude, coordinates.longitude)
        }

        return BookingInfoViewModel(
            primePassID: restaurant.primePassID,
            title: restaurant.title,
            address: restaurant.address,
            distanceText: distanceText,
            imageURL: restaurant.images.first?.image,
            rating: rating,
            ratingFloat: assessment?.rating,
            assessmentsCountText: FormatterHelper.assessments(assessment?.number ?? 0),
            assessmentsCount: assessment?.number,
            price: restaurant.price,
            coordinate: coordninate,
            booking: booking,
            reviewRating: reviewRating,
			isCancellable: isCancellable,
            isMobileOriginated: isMobileOriginated, 
            cancelTitle: cancelTitle
        )
    }
}
