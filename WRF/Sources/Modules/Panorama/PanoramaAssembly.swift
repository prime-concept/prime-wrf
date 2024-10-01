import UIKit

struct PanoramaSeed {
    let images: [(image: URL, preview: URL)]
}

final class PanoramaAssembly: Assembly {
    private let seed: PanoramaSeed

    init(seed: PanoramaSeed) {
        self.seed = seed
    }

    func makeModule() -> UIViewController {
        let viewController = PanoramaViewController(seed: self.seed)
        return viewController
    }
}
