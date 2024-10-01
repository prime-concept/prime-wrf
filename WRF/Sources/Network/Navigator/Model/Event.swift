import Foundation

// swiftlint:disable discouraged_optional_collection
// swiftlint:disable discouraged_optional_boolean
struct Event: Decodable {
    typealias IDType = String

    let id: IDType
    let title: String
    let description: String?
    let bookingText: String?
    var isFavorite: Bool
    let schedule: [Date]
    let restaurantsIDs: [Restaurant.IDType]?
    let images: [GradientImage]?
    let partnerLink: String?
    let tagsIDs: [Tag.IDType]?

    let bookingLink: String?
    let buttonName: String?

    init(
        id: IDType,
        title: String = "",
        description: String? = nil,
        bookingText: String? = nil,
        isFavorite: Bool = false,
        schedule: [Date] = [],
        restaurantsIDs: [Restaurant.IDType]? = nil,
        images: [GradientImage]? = nil,
        partnerLink: String? = nil,
        tagsIDs: [Tag.IDType]? = nil,
        bookingLink: String? = nil,
        buttonName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.bookingText = bookingText
        self.isFavorite = isFavorite
        self.schedule = schedule
        self.restaurantsIDs = restaurantsIDs
        self.images = images
        self.partnerLink = partnerLink
        self.tagsIDs = tagsIDs
        self.bookingLink = bookingLink
        self.buttonName = buttonName
    }

    func copyWithUpdatingParameters(description: String? = nil, isFavorite: Bool? = nil) -> Event {
        return Event(
            id: self.id,
            title: self.title,
            description: description ?? self.description,
            bookingText: self.bookingText,
            isFavorite: isFavorite ?? self.isFavorite,
            schedule: self.schedule,
            restaurantsIDs: self.restaurantsIDs,
            images: self.images,
            partnerLink: self.partnerLink,
            tagsIDs: self.tagsIDs,
            bookingLink: self.bookingLink,
            buttonName: self.buttonName
        )
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case bookingText = "about_booking"
        case isFavorite = "is_favorite"
        case schedule = "small_schedule"
        case restaurantsIDs = "restaurants_ids"
        case images
        case partnerLink = "partner_link"
        case tagsIDs = "tags_ids"
        case buttonName = "button_name"
        case bookingLink = "booking_link"
    }
}
