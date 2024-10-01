import UIKit

final class MyCardAssembly: Assembly {
    var moduleInput: ProfileClientModuleInput {
        return self.presenter
    }

    private lazy var presenter = MyCardPresenter(
        clientEndpoint: PrimePassClientEndpoint(),
        loyaltyEndpoint: PrimePassLoyaltyEndpoint(),
        clientService: ClientService.shared,
        authService: AuthService(), 
        bonusEndpoint: BonusesEndpoint()
    )

    func makeModule() -> UIViewController {
        let viewController = MyCardViewController(presenter: self.presenter)
        self.presenter.viewController = viewController

        return viewController
    }
}
