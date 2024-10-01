import Branch
import Foundation

protocol SharingServiceProtocol {
    func share(object: DeeplinkContext)
}

class SharingService: SharingServiceProtocol {
    func share(object: DeeplinkContext) {
        object.buo.showShareSheet(
            with: object.linkProperties,
            andShareText: PGCMain.shared.text.shareText,
            from: nil,
            completion: nil
        )
    }
}
