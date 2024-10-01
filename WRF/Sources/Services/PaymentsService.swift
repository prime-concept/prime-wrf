import Foundation
import PromiseKit
import SwiftKeychainWrapper

protocol PaymentsServiceProtocol {
    func add(payment: Payment)
    func save(payment: Payment)
    func remove(payment: Payment)
    func getPayments() -> [Payment]

    func findCardType(card number: String?) -> CardType
}

final class PaymentsService: PaymentsServiceProtocol {
    static let keychainKey = "payments"

    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    private let keychain = KeychainWrapper.standard

    private let visaRegex = try? NSRegularExpression(pattern: "^4[0-9]{12}(?:[0-9]{3})?$", options: [])

    // MARK: - Public API

    func add(payment: Payment) {
        var payments = self.getPayments()
        payments.append(payment)
        self.save(payments: payments)
    }

    func save(payment: Payment) {
        var payments = self.getPayments()
        if let row = payments.firstIndex(where: { $0.id == payment.id }) {
            payments[row] = payment
            self.save(payments: payments)
        }
    }

    func remove(payment: Payment) {
        let payments = self.getPayments().filter { $0.id != payment.id }
        self.save(payments: payments)
    }

    func getPayments() -> [Payment] {
        return self.retrieve()
    }

    func findCardType(card number: String?) -> CardType {
        guard let number = number,
              !number.isEmpty,
              number.count == 16 else {
            return .none
        }
        let range = NSRange(location: 0, length: number.count)
        if self.visaRegex?.firstMatch(in: number, options: [], range: range) != nil {
            return .visa
        }
        return .master
    }

    // MARK: - Private API

    private func save(payments: [Payment]) {
        do {
            let data = try self.jsonEncoder.encode(payments)
            self.keychain.set(data, forKey: PaymentsService.keychainKey)
        } catch {
            print("payments service: error while saving payments - \(error.localizedDescription)")
        }
    }

    private func retrieve() -> [Payment] {
        guard let data = self.keychain.data(forKey: PaymentsService.keychainKey),
              let payments = try? self.jsonDecoder.decode([Payment].self, from: data) else {
            return []
        }
        return payments
    }
}
