import UIKit

final class WebFrameAssembly: Assembly {
    private let frameData: WebFrameData

    init(frameData: WebFrameData) {
        self.frameData = frameData
    }

    func makeModule() -> UIViewController {
        return WebFrameViewController(
            frameData: self.frameData,
            authService: AuthService(),
            locationService: LocationService.shared
        )
    }
}
