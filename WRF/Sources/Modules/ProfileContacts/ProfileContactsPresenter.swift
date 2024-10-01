import PromiseKit
import UIKit

protocol ProfileContactsPresenterProtocol {
    func loadContacts()
    func select(at index: Int)
}

final class ProfileContactsPresenter: ProfileContactsPresenterProtocol {
    weak var viewController: ProfileContactsViewControllerProtocol?

    private let endpoint: ContactsEndpointProtocol

    private var contacts: [Contacts.Contact] = []

    init(endpoint: ContactsEndpointProtocol) {
        self.endpoint = endpoint
    }

    func loadContacts() {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.endpoint.retrieve().result
        }.done { contacts in
            self.contacts = contacts.items

            let models = contacts.items.map(self.makeViewModel).compactMap { $0 }
            self.viewController?.set(contacts: models)
        }.catch { error in
            print("contacts presenter: error retrieving contacts \(String(describing: error))")
        }
    }

    func select(at index: Int) {
        guard let contact = self.contacts[safe: index], let type = contact.type, let value = contact.value else {
            return
        }

        switch type {
        case .email:
            if let emailUrl = URL(string: "mailto:\(value)") {
                self.viewController?.open(url: emailUrl)
            }
        case .phone:
            if let phoneURL = URL(string: "tel://\(value)") {
                self.viewController?.open(url: phoneURL)
            }
        }
    }

    // MARK: - Private API

    private func makeViewModel(contact: Contacts.Contact) -> ProfileContactItemViewModel? {
        guard let title = contact.title, let value = contact.value else {
            return nil
        }

        return ProfileContactItemViewModel(title: title, value: value)
    }
}
