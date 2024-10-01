import Foundation

// swiftlint:disable discouraged_optional_collection
// swiftlint:disable discouraged_optional_boolean
struct Restaurant: Decodable, Hashable {
    typealias IDType = String

    let id: IDType
    let hostessScheduleKey: IDType
    let title: String
    let description: String?
    let coordinates: Coordinate?
    let eventsIDs: [Event.IDType]?

    let tagsIDs: [Tag.IDType]?
    let tagsRestaurantsIDs: [Tag.IDType]?
    let restServicesIDs: [Tag.IDType]?
    let cuisinesIDs: [Tag.IDType]?
    let specialIDs: [Tag.IDType]?

    let primePassID: PrimePassRestaurantIDType
    let address: String
    var isFavorite: Bool
    let images: [GradientImage]
    let images360: [GradientImage]?
    let previewImages360: [GradientImage]?
    let workingTime: WorkingTime?
    let price: String?
    let phone: String?
    let site: String?
    let menu: String?
    let logos: [GradientImage]?

    let deliveryLink: String?
    let deliveryTime: String?
    let isClosed: Bool?
    let canReserve: Bool?
    let canBookOnline: Bool

    init(
        id: IDType,
        hostessScheduleKey: IDType = "",
        title: String = "",
        description: String? = nil,
        coordinates: Coordinate? = Coordinate(latitude: 0, longitude: 0),
        eventsIDs: [Event.IDType]? = nil,
        tagsIDs: [Tag.IDType]? = nil,
        tagsRestaurantsIDs: [Tag.IDType]? = nil,
        restServicesIDs: [Tag.IDType]? = nil,
        cuisinesIDs: [Tag.IDType]? = nil,
        specialIDs: [Tag.IDType]? = nil,
        primePassID: PrimePassRestaurantIDType = "",
        address: String = "",
        isFavorite: Bool = false,
        images: [GradientImage] = [],
        images360: [GradientImage]? = nil,
        previewImages360: [GradientImage]? = nil,
        workingTime: WorkingTime? = nil,
        price: String? = nil,
        phone: String? = nil,
        site: String? = nil,
        menu: String? = nil,
        logos: [GradientImage]? = nil,
        deliveryLink: String? = nil,
        deliveryTime: String? = nil,
        isClosed: Bool? = nil,
        canReserve: Bool? = nil,
        canBookOnline: Bool = false
    ) {
        self.id = id
        self.hostessScheduleKey = hostessScheduleKey
        self.title = title
        self.description = description
        self.coordinates = coordinates
        self.eventsIDs = eventsIDs
        self.tagsIDs = tagsIDs
        self.tagsRestaurantsIDs = tagsRestaurantsIDs
        self.restServicesIDs = restServicesIDs
        self.cuisinesIDs = cuisinesIDs
        self.specialIDs = specialIDs
        self.primePassID = primePassID
        self.address = address
        self.isFavorite = isFavorite
        self.images = images
        self.images360 = images360
        self.previewImages360 = previewImages360
        self.workingTime = workingTime
        self.price = price
        self.phone = phone
        self.site = site
        self.menu = menu
        self.logos = logos
        self.deliveryLink = deliveryLink
        self.deliveryTime = deliveryTime
        self.isClosed = isClosed
        self.canReserve = canReserve
        self.canBookOnline = canBookOnline
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.id == rhs.id
    }

    func copyWithUpdatingParameters(
        description: String?,
        phone: String?,
        menu: String?,
        site: String?,
        previewImages360: [GradientImage],
        eventIDs: [Event.IDType]?
    ) -> Restaurant {
        return Restaurant(
            id: self.id,
            hostessScheduleKey: self.hostessScheduleKey,
            title: self.title,
            description: description,
            coordinates: self.coordinates,
            eventsIDs: eventIDs,
            tagsIDs: self.tagsIDs,
            tagsRestaurantsIDs: self.tagsRestaurantsIDs,
            restServicesIDs: self.restServicesIDs,
            cuisinesIDs: self.cuisinesIDs,
            specialIDs: self.specialIDs,
            primePassID: self.primePassID,
            address: self.address,
            isFavorite: self.isFavorite,
            images: self.images,
            images360: self.images360,
            previewImages360: previewImages360,
            workingTime: self.workingTime,
            price: self.price,
            phone: phone,
            site: site,
            menu: menu,
            logos: logos,
            deliveryLink: self.deliveryLink,
            deliveryTime: self.deliveryTime,
            isClosed: self.isClosed,
            canReserve: self.canReserve,
            canBookOnline: self.canBookOnline
        )
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case coordinates
        case images
        case logos = "logo"
        case eventsIDs = "events_ids"
        case primePassID = "primepass_id"
        case address
        case isFavorite = "is_favorite"
        case images360
        case previewImages360 = "images360_100x100"
        case workingTime = "working_time"
        case price
        case phone
        case site
        case menu = "menu_link"
        case tagsIDs = "tags_ids"
        case tagsRestaurantsIDs = "tags_restaurants_ids"
        case restServicesIDs = "rest_services_ids"
        case cuisinesIDs = "cuisines_ids"
        case specialIDs = "special_ids"
        case deliveryLink = "delivery_link"
        case deliveryTime = "delivery_time"
        case isClosed = "is_closed"
        case canReserve = "can_reserve"
        case canBookOnline = "can_book_online"
        case hostessScheduleKey = "hostess_schedule_key"
    }
    
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<Restaurant.CodingKeys> = try decoder.container(keyedBy: Restaurant.CodingKeys.self)
        
        self.id = try container.decode(Restaurant.IDType.self, forKey: Restaurant.CodingKeys.id)
        self.hostessScheduleKey = try container.decode(Restaurant.IDType.self, forKey: Restaurant.CodingKeys.hostessScheduleKey)
        self.title = try container.decode(String.self, forKey: Restaurant.CodingKeys.title)
        self.description = try container.decodeIfPresent(String.self, forKey: Restaurant.CodingKeys.description)
        self.coordinates = try? container.decodeIfPresent(Coordinate.self, forKey: Restaurant.CodingKeys.coordinates)
        self.images = try container.decode([GradientImage].self, forKey: Restaurant.CodingKeys.images)
        self.logos = try container.decodeIfPresent([GradientImage].self, forKey: Restaurant.CodingKeys.logos)
        self.eventsIDs = try container.decodeIfPresent([Event.IDType].self, forKey: Restaurant.CodingKeys.eventsIDs)
        self.primePassID = try container.decode(PrimePassRestaurantIDType.self, forKey: Restaurant.CodingKeys.primePassID)
        self.address = try container.decode(String.self, forKey: Restaurant.CodingKeys.address)
        self.isFavorite = try container.decode(Bool.self, forKey: Restaurant.CodingKeys.isFavorite)
        self.images360 = try container.decodeIfPresent([GradientImage].self, forKey: Restaurant.CodingKeys.images360)
        self.previewImages360 = try container.decodeIfPresent([GradientImage].self, forKey: Restaurant.CodingKeys.previewImages360)
        self.workingTime = try container.decodeIfPresent(WorkingTime.self, forKey: Restaurant.CodingKeys.workingTime)
        self.price = try container.decodeIfPresent(String.self, forKey: Restaurant.CodingKeys.price)
        self.phone = try container.decodeIfPresent(String.self, forKey: Restaurant.CodingKeys.phone)
        self.site = try container.decodeIfPresent(String.self, forKey: Restaurant.CodingKeys.site)
        self.menu = try container.decodeIfPresent(String.self, forKey: Restaurant.CodingKeys.menu)
        self.tagsIDs = try container.decodeIfPresent([Tag.IDType].self, forKey: Restaurant.CodingKeys.tagsIDs)
        self.tagsRestaurantsIDs = try container.decodeIfPresent([Tag.IDType].self, forKey: Restaurant.CodingKeys.tagsRestaurantsIDs)
        self.restServicesIDs = try container.decodeIfPresent([Tag.IDType].self, forKey: Restaurant.CodingKeys.restServicesIDs)
        self.cuisinesIDs = try container.decodeIfPresent([Tag.IDType].self, forKey: Restaurant.CodingKeys.cuisinesIDs)
        self.specialIDs = try container.decodeIfPresent([Tag.IDType].self, forKey: Restaurant.CodingKeys.specialIDs)
        self.deliveryLink = try container.decodeIfPresent(String.self, forKey: Restaurant.CodingKeys.deliveryLink)
        self.deliveryTime = try container.decodeIfPresent(String.self, forKey: Restaurant.CodingKeys.deliveryTime)
        self.isClosed = try container.decodeIfPresent(Bool.self, forKey: Restaurant.CodingKeys.isClosed)
        self.canReserve = try container.decodeIfPresent(Bool.self, forKey: Restaurant.CodingKeys.canReserve)
        self.canBookOnline = try container.decodeIfPresent(Bool.self, forKey: Restaurant.CodingKeys.canBookOnline) ?? false
    }
}
