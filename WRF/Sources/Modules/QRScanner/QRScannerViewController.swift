import UIKit

protocol QRScannerViewControllerProtocol: AnyObject {
    func showFailure()
    func showSuccess(message: String)
}

final class QRScannerViewController: UIViewController {
    let presenter: QRScannerPresenterProtocol
    lazy var qrScannerView = self.view as? QRScannerView

    init(presenter: QRScannerPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)

        self.hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = QRScannerView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Сканирование QR"

        self.qrScannerView?.update(state: .scan)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.qrScannerView?.startSessionIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.qrScannerView?.stopSessionIfNeeded()
    }
}

extension QRScannerViewController: QRScannerViewControllerProtocol {
    func showFailure() {
        self.qrScannerView?.update(state: .failure)
    }

    func showSuccess(message: String) {
        self.qrScannerView?.update(state: .success(message: message))
    }
}

extension QRScannerViewController: QRScannerViewDelegate {
    func qrScannerViewCodeRecognized(_ view: QRScannerView, code: String) {
        self.qrScannerView?.update(state: .send)
        self.presenter.sendResult(number: code)
    }

    func qrScannerViewBackActionRequested(_ view: QRScannerView) {
        self.navigationController?.popViewController(animated: true)
    }

    func qrScannerViewTryAgainActionRequested(_ view: QRScannerView) {
        self.qrScannerView?.update(state: .scan)
    }
}
