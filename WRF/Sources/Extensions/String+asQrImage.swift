import PromiseKit
import UIKit

extension String {
	private static let ciContext = CIContext()

	func qrImage(scale: CGFloat) -> UIImage? {
		let data = self.data(using: .utf8)
		guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
			return nil
		}
		qrFilter.setValue(data, forKey: "inputMessage")

		guard let qrImage = qrFilter.outputImage else {
			return nil
		}

		let transform = CGAffineTransform(scaleX: scale, y: scale)
		let scaledQrImage = qrImage.transformed(by: transform)

		let colorInvertFilter = CIFilter(name: "CIColorInvert")
		colorInvertFilter?.setValue(scaledQrImage, forKey: "inputImage")

		let alphaFilter = CIFilter(name: "CIMaskToAlpha")
		alphaFilter?.setValue(colorInvertFilter?.outputImage, forKey: "inputImage")
		guard let outputImage = alphaFilter?.outputImage else {
			return nil
		}

		if let cgImage = Self.ciContext.createCGImage(outputImage, from: outputImage.extent) {
			return UIImage(cgImage: cgImage).withRenderingMode(.alwaysTemplate)
		}

		return nil
	}

	var asQrImage: UIImage? {
		self.qrImage(scale: 10)
	}
}
