import PromiseKit
import UIKit

protocol MyCardInfoPresenterProtocol {
    func loadCard()
}

final class MyCardInfoPresenter: MyCardInfoPresenterProtocol {
    weak var viewController: MyCardInfoViewControllerProtocol?

    private let client: PrimePassClient

    init(client: PrimePassClient) {
        self.client = client
    }

    func loadCard() {
        self.viewController?.set(model: self.makeViewModel(client: self.client))
    }

    // MARK: - Private API

    private func makeViewModel(client: PrimePassClient) -> MyCardInfoViewModel {
        return MyCardInfoViewModel(
            gradeName: client.card.gradeName,
            description: self.makeCardDescription(card: client.card),
            userImage: client.photo?.asImage,
			balance: "баллов".pluralized("%d %@", client.bonusBalance, Self.pointsNumberFormatter)
        )
    }

	private static let pointsNumberFormatter = with(NumberFormatter()) { numberFormatter in
		numberFormatter.usesGroupingSeparator = true
		numberFormatter.groupingSeparator = " "
		numberFormatter.groupingSize = 3
	}

    private func makeCardDescription(card: PrimePassCard) -> String {
		let courseBalls = "баллов".pluralized("%d %@", card.courseBonus, Self.pointsNumberFormatter)
		let courseRub = "рублей".pluralized("за %d %@", card.courseRub, Self.pointsNumberFormatter)
		let nextLevelBalls = "баллов".pluralized("%d %@", card.nextGradeUpgradeAmount ?? 0, Self.pointsNumberFormatter)

        return "Уровень: \(card.gradeName). \(courseBalls) за \(courseRub). До следующего уровня: \(nextLevelBalls)"
    }
}
