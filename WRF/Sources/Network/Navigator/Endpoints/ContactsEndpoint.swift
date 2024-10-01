import Alamofire
import Foundation
import PromiseKit

protocol ContactsEndpointProtocol: AnyObject {
    func retrieve() -> EndpointResponse<Contacts>
}

final class ContactsEndpoint: NavigatorEndpoint, ContactsEndpointProtocol {
    static let endpoint = "/screens/contacts"

    func retrieve() -> EndpointResponse<Contacts> {
        return self.retrieve(endpoint: ContactsEndpoint.endpoint)
    }
}
