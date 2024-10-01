import Branch
import Foundation

enum DeeplinkContext {
    /// Переход в профиль, показ забронированного ресторана
    case booking(id: HostessBooking.IDType)

    /// Переход на детейл события
    case event(id: String, Event?)

    /// Переход на детейл ресторана
    case restaurant(id: String, Restaurant?)

    /// Переход на страницу таббара, смотреть WRFTabBarController.Tabs
    case tabbar(page: RootTabBarController.Tabs)

    /// Переход на проигрование первого видео
    case video

    /// Переход на страницу уведомлений
    case notifications

    /// Переход на доставку ресторана
    case delivery(id: String)

	/// Переход в профиль на карту Лояльности
	case loyaltyCard

	/// Переход в профиль на Историю бронирования
	case bookingHistory

    case webView(url: URL)
    case chat(token: String, channelID: String, channelName: String, clientID: String)

    var buo: BranchUniversalObject {
         switch self {
         case .event(let id, let event):
             let buo = BranchUniversalObject(canonicalIdentifier: "event/\(id)")
            if let event = event {
                buo.title = event.title
                buo.contentDescription = event.description
                buo.imageUrl = event.images?.first.flatMap { $0.image.absoluteString }
            }
            return buo
         case .restaurant(let id, let restaurant):
            let buo = BranchUniversalObject(canonicalIdentifier: "restaurant/\(id)")
            if let restaurant = restaurant {
                buo.title = restaurant.title
                buo.contentDescription = restaurant.description
                buo.imageUrl = restaurant.images.first.flatMap { $0.image.absoluteString }
            }
            return buo
         default:
            fatalError("Not implemented action")
         }
     }

     var linkProperties: BranchLinkProperties {
         let linkProperties = BranchLinkProperties()
         switch self {
         case .event(let id, _):
            linkProperties.addControlParam("screen", withValue: "event")
            linkProperties.addControlParam("id", withValue: id)
         case .restaurant(let id, _):
            linkProperties.addControlParam("screen", withValue: "restaurant")
            linkProperties.addControlParam("id", withValue: id)
         default:
            fatalError("Not implemented action")
         }
         return linkProperties
     }

    init?(data: [String: AnyObject]) {
        guard let path = data["$canonical_identifier"] ?? data["+non_branch_link"] else {
            return nil
        }

        let components = path.components(separatedBy: "/")

        guard components.count >= 1 else {
            return nil
        }

        let name = components[0]

        if components.count == 2 {
            let value = components[1]

            switch name {
            case "event":
                self = .event(id: value, nil)
            case "restaurant":
                self = .restaurant(id: value, nil)
            case "tabbar":
                guard let page = RootTabBarController.Tabs(from: value) else {
                    assertionFailure("uknown page")
                    return nil
                }
                self = .tabbar(page: page)
            case "delivery":
                self = .delivery(id: value)
			case "webview":
				guard let urlString = value.removingPercentEncoding,
					  let url = URL(string: urlString) else {
					return nil
				}
				self = .webView(url: url)
            default:
                return nil
            }
        } else {
            switch name {
            case "notifications":
                self = .notifications
            case "video":
                self = .video
			case "home":
				let page = RootTabBarController.Tabs.map
				self = .tabbar(page: page)
			case "loyaltyCard":
				self = .loyaltyCard
			case "bookingHistory":
				self = .bookingHistory
            default:
                return nil
            }
        }
    }
}

// MARK: - Booking deeplink story

protocol BookingDeeplinkRoutable: UIViewController {
    var nextStoryRoutable: BookingDeeplinkRoutable? { get }
    func route(bookingID: HostessBooking.IDType)
}
