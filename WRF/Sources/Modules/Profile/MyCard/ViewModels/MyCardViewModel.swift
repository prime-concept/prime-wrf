import UIKit

struct MyCardViewModel {
    let fullName: String
    let gradeName: String
    let discountPercent: String?
    let balance: String
    let userImage: UIImage?
    let qrImage: UIImage?
    let cardNumber: String?
    let shouldRetryQRCode: Bool
    let isQRCodeLoading: Bool
}
