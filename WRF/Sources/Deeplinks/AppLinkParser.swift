import Foundation

protocol AppLinkParserProtocol: AnyObject {
    func tryToOpen(url: URL, completion: ((DeeplinkContext?) -> Void)?) -> Bool
}

/// Companion for DeeplinkRouter to open app-links (DeepLinkRouter also can be standalone e.g for Branch universal links)
final class AppLinkParser: AppLinkParserProtocol {
    typealias CompletionType = ((DeeplinkContext?) -> Void)?

    func tryToOpen(data: [String: AnyObject], completion: CompletionType) {
		let context = DeeplinkContext(data: data)
        completion?(context)
    }

    func tryToOpen(url: URL, completion: CompletionType) -> Bool {
        guard let host = url.host else {
            print("app link parser: url should be valid url, url = \(url.debugDescription)")
            return false
        }

        switch host {
        case "booking":
            return self.handleBooking(url: url, completion: completion)
        case "webview":
            return self.handleWebview(url: url, completion: completion)
        case "chat":
            return self.handleChat(url: url, completion: completion)
        case "event":
            return self.handleEvent(url: url, completion: completion)
        case "restaurant":
            return self.handleRestaurant(url: url, completion: completion)
        case "tabbar":
            return self.handleTabbBar(url: url, completion: completion)
		case "home":
			return self.handleHome(completion: completion)
        case "video":
            return self.handleVideo(url: url, completion: completion)
        case "notifications":
            return self.handleNotifications(url: url, completion: completion)
        case "delivery":
            return self.handleDelivery(url: url, completion: completion)
		case "loyaltyCard":
			return self.handleLoyaltyCard(completion: completion)
		case "bookingHistory":
			return self.handleBookingHistory(completion: completion)
        default:
            assertionFailure("app link parser: unknown url = \(url.debugDescription)")
        }

        completion?(nil)
        return false
    }

    private func handleBooking(url: URL, completion: CompletionType) -> Bool {
        guard let bookingID = type(of: self).queryParameter(from: url, name: "id"),
              let bookingIntID = Int(bookingID) else {
            print("app link parser: booking id is invalid, url = \(url.debugDescription)")
            return false
        }

        let context = DeeplinkContext.booking(id: bookingIntID)

        completion?(context)
        return true
    }

    private func handleWebview(url: URL, completion: CompletionType) -> Bool {
        guard let urlPath = Self.queryParameter(from: url, name: "url"),
              let targetURL = URL(
                  string: urlPath.removingPercentEncoding ?? ""
              ) else {
            print("app link parser: url is invalid, url = \(url.debugDescription)")
            return false
        }

        let context = DeeplinkContext.webView(url: targetURL)

        completion?(context)
        return true
    }

    private func handleEvent(url: URL, completion: CompletionType) -> Bool {
        guard let id = Self.queryParameter(from: url, name: "id") else {
            print("app link parser: url is invalid, url = \(url.debugDescription)")
            return false
        }

        let context = DeeplinkContext.event(id: id, nil)

        completion?(context)
        return true
    }

    private func handleRestaurant(url: URL, completion: CompletionType) -> Bool {
        guard let id = Self.queryParameter(from: url, name: "id") else {
            print("app link parser: url is invalid, url = \(url.debugDescription)")
            return false
        }

        let context = DeeplinkContext.restaurant(id: id, nil)

        completion?(context)
        return true
    }

    private func handleTabbBar(url: URL, completion: CompletionType) -> Bool {
        guard
            let path = Self.queryParameter(from: url, name: "page"),
            let page = RootTabBarController.Tabs(from: path)
        else {
            print("app link parser: url is invalid, url = \(url.debugDescription)")
            return false
        }

        let context = DeeplinkContext.tabbar(page: page)

        completion?(context)
        return true
    }

	private func handleHome(completion: CompletionType) -> Bool {
		let page = RootTabBarController.Tabs.map
		let context = DeeplinkContext.tabbar(page: page)

		completion?(context)
		return true
	}

    private func handleVideo(url: URL, completion: CompletionType) -> Bool {
        let context = DeeplinkContext.video

        completion?(context)
        return true
    }

    private func handleNotifications(url: URL, completion: CompletionType) -> Bool {
        let context = DeeplinkContext.notifications

        completion?(context)
        return true
    }

    private func handleDelivery(url: URL, completion: CompletionType) -> Bool {
        guard let id = Self.queryParameter(from: url, name: "id") else {
            print("app link parser: url is invalid, url = \(url.debugDescription)")
            return false
        }

        let context = DeeplinkContext.delivery(id: id)

        completion?(context)
        return true
    }

	private func handleLoyaltyCard(completion: CompletionType) -> Bool {
		let context = DeeplinkContext.loyaltyCard
		completion?(context)
		return true
	}

	private func handleBookingHistory(completion: CompletionType) -> Bool {
		let context = DeeplinkContext.bookingHistory
		completion?(context)
		return true
	}


    private func handleChat(url: URL, completion: CompletionType) -> Bool {
        guard let channelID = Self.queryParameter(from: url, name: "channelid"),
              let channelName = Self.queryParameter(from: url, name: "channelname"),
              let token = Self.queryParameter(from: url, name: "token"),
              let clientID = Self.queryParameter(from: url, name: "clientid") else {
            print("app link parser: chat deeplink invalid, url = \(url.debugDescription)")
            return false
        }

        let context = DeeplinkContext.chat(
            token: token,
            channelID: channelID,
            channelName: channelName,
            clientID: clientID
        )

        completion?(context)
        return true
    }

    private static func queryParameter(from url: URL, name: String) -> String? {
        guard let url = URLComponents(string: url.absoluteString) else {
            return nil
        }
        return url.queryItems?.first(where: { $0.name == name })?.value
    }
}
