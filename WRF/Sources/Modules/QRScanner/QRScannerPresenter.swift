import UIKit

protocol QRScannerPresenterProtocol {
    func sendResult(number: String)
}

final class QRScannerPresenter: QRScannerPresenterProtocol {
    weak var viewController: QRScannerViewControllerProtocol?

    private let endpoint: PrimePassCodeEndpointProtocol
    private let authService: AuthServiceProtocol

    private var codeAlreadySent = false

    init(endpoint: PrimePassCodeEndpointProtocol, authService: AuthServiceProtocol) {
        self.endpoint = endpoint
        self.authService = authService
    }

    func sendResult(number: String) {
        if self.codeAlreadySent {
            return
        }

        guard let userID = self.authService.authorizationData?.userID else {
            return
        }

        self.codeAlreadySent = true

        let request = PrimePassCodeRequest(userID: userID, number: number)

        let queue = DispatchQueue.global(qos: .default)
        queue.promise {
            self.endpoint.send(request: request).result
        }.done { response in
            let message = response.data ?? "Успешно. Вскоре вам будут начислены бонусные баллы"
            let error = response.error

            if error?.message == nil {
                self.viewController?.showSuccess(message: message)
            } else {
                self.viewController?.showFailure()
            }
        }.ensure {
            self.codeAlreadySent = false
        }.catch { _ in
            self.viewController?.showFailure()
        }
    }
}
