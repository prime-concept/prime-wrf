import UIKit

final class PhotosAssembly: Assembly {
    private let restaurant: Restaurant
    private let selectedIndex: Int

    init(restaurant: Restaurant, selectedIndex: Int) {
        self.restaurant = restaurant
        self.selectedIndex = selectedIndex
    }

    func makeModule() -> UIViewController {
        let viewController = PhotosViewController(
            restaurant: self.restaurant,
            selectedIndex: self.selectedIndex
        )
        return viewController
    }
}
