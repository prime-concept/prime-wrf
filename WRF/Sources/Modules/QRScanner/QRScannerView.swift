// swiftlint:disable shortening
import AVFoundation
import AVKit
import SnapKit
import UIKit

protocol QRScannerViewDelegate: AnyObject {
    func qrScannerViewCodeRecognized(_ view: QRScannerView, code: String)
    func qrScannerViewBackActionRequested(_ view: QRScannerView)
    func qrScannerViewTryAgainActionRequested(_ view: QRScannerView)
}

extension QRScannerView {
    enum State {
        case scan
        case send
        case success(message: String)
        case failure

        var title: String? {
            switch self {
            case .send:
                return "Обработка. Это может занять несколько секунд"
            case .failure:
                return "Ошибка. Попробуйте еще раз"
            case .success(let message):
                return message
            default:
                return nil
            }
        }

        var image: UIImage? {
            switch self {
            case .send:
                return #imageLiteral(resourceName: "booking-waiting")
            case .failure:
                return #imageLiteral(resourceName: "booking-result-error")
            case .success:
                return #imageLiteral(resourceName: "booking-result-success")
            default:
                return nil
            }
        }
    }

    struct Appearance {
        let overlayColor = UIColor.black.withAlphaComponent(0.6)
        let frameColor = UIColor.white
        let frameBorderWidth: CGFloat = 2
        let frameBorderCornerRadius: CGFloat = 5
        let frameSize = CGSize(width: 205, height: 205)
        let frameTopOffset: CGFloat = 80

        let tipLabelFont = UIFont.wrfFont(ofSize: 16)
        let tipLabelBackgroundColor = UIColor.white
        let tipLabelTextColor = UIColor.black
        let tipLabelLineHeight: CGFloat = 16
        let tipLabelInsets = LayoutInsets(left: 15)

        let tipBackgroundViewCornerRadius: CGFloat = 15
        let tipBackgroundViewInsets = LayoutInsets(left: 15, bottom: 15, right: 15)

        let iconSize = CGSize(width: 80, height: 80)
        let mainFont = UIFont.wrfFont(ofSize: 16)
        let mainTextColor = UIColor.black
        let mainEditorLineHeight: CGFloat = 21

        let spacing: CGFloat = 20
        let statusInsets = LayoutInsets(left: 35, right: 35)
        let statusTopOffset: CGFloat = -40

        let resultButtonColor = UIColor.black
        let resultButtonTextColor = UIColor.white
        let resultButtonFont = UIFont.wrfFont(ofSize: 14)
        let resultButtonHeight: CGFloat = 40
        let resultButtonInsets = LayoutInsets(left: 15, bottom: 15, right: 15)
        let resultButtonCornerRadius: CGFloat = 8
    }
}

final class QRScannerView: UIView {
    weak var delegate: QRScannerViewDelegate?
    let appearance: Appearance

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var currentState: State?

    private lazy var backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)

    private lazy var overlayLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = self.appearance.overlayColor.cgColor
        layer.fillRule = .evenOdd
        return layer
    }()

    private lazy var qrCodeFrameLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.borderColor = self.appearance.frameColor.cgColor
        layer.borderWidth = self.appearance.frameBorderWidth
        layer.fillColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = self.appearance.frameBorderCornerRadius
        return layer
    }()

    private lazy var tipLabel: UILabel = {
        let label = PaddingLabel()
        label.backgroundColor = self.appearance.tipLabelBackgroundColor
        label.font = self.appearance.tipLabelFont
        label.textColor = self.appearance.tipLabelTextColor
        label.text = "Поместите QR-код в область в\u{00a0}центре\u{00a0}экрана"
        label.lineBreakMode = .byWordWrapping
        label.insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        label.numberOfLines = 2

        label.clipsToBounds = true
        label.layer.cornerRadius = self.appearance.tipBackgroundViewCornerRadius
        return label
    }()

    private lazy var statusIconView = UIImageView()

    private lazy var statusImageViewContainerView = UIView()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.mainFont
        label.textColor = self.appearance.mainTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var statusStackView: UIStackView = {
        let view = UIStackView(
            arrangedSubviews: [self.statusImageViewContainerView, self.statusLabel]
        )
        view.axis = .vertical
        view.spacing = self.appearance.spacing
        return view
    }()

    private lazy var resultButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = self.appearance.resultButtonColor
        button.setTitleColor(self.appearance.resultButtonTextColor, for: .normal)
        button.titleLabel?.font = self.appearance.resultButtonFont
        button.setTitle("Оставить", for: .normal)

        button.clipsToBounds = true
        button.layer.cornerRadius = self.appearance.resultButtonCornerRadius

        button.addTarget(self, action: #selector(self.resultButtonClicked), for: .touchUpInside)
        return button
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.relayoutPreviewLayer()
    }

    func startSessionIfNeeded() {
        if self.captureSession?.isRunning == false {
            self.captureSession?.startRunning()
        }
    }

    func stopSessionIfNeeded() {
        if self.captureSession?.isRunning == true {
            self.captureSession?.stopRunning()
        }
    }

    func update(state: State) {
        self.currentState = state

        switch state {
        case .scan:
            self.startSessionIfNeeded()
            self.previewLayer?.isHidden = false
            self.overlayLayer.isHidden = false
            self.tipLabel.isHidden = false
            self.statusStackView.isHidden = true
            self.resultButton.isHidden = true

        case .send:
            self.stopSessionIfNeeded()
            self.previewLayer?.isHidden = true
            self.overlayLayer.isHidden = true
            self.tipLabel.isHidden = true
            self.statusStackView.isHidden = false
            self.resultButton.isHidden = true

        case .success:
            self.stopSessionIfNeeded()
            self.resultButton.isHidden = false
            self.resultButton.setTitle("Вернуться", for: .normal)

        case .failure:
            self.stopSessionIfNeeded()
            self.resultButton.isHidden = false
            self.resultButton.setTitle("Повторить", for: .normal)
        }

        self.statusLabel.attributedText = LineHeightStringMaker.makeString(
            state.title ?? "",
            editorLineHeight: self.appearance.mainEditorLineHeight,
            font: self.appearance.mainFont,
            alignment: .center
        )

        self.statusIconView.image = state.image
    }

    // MARK: - Private

    @objc
    private func resultButtonClicked() {
        guard let state = self.currentState else {
            return
        }

        if case .failure = state {
            self.delegate?.qrScannerViewTryAgainActionRequested(self)
        } else {
            self.delegate?.qrScannerViewBackActionRequested(self)
        }
    }

    private func getCurrentQRFrameRect() -> CGRect {
        let bounds = self.bounds
        let size = self.appearance.frameSize

        return CGRect(
            x: bounds.width / 2 - size.width / 2,
            y: bounds.height / 2 - size.height / 2 - self.appearance.frameTopOffset,
            width: size.width,
            height: size.height
        )
    }

    private func setupPreviewLayer() {
        guard let session = self.captureSession else {
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(previewLayer)
        self.layer.addSublayer(self.overlayLayer)
        self.layer.addSublayer(self.qrCodeFrameLayer)

        self.previewLayer = previewLayer
    }

    private func setupAudioVideo() {
        guard let captureDevice = self.backCameraDevice else {
            return
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            return
        }

        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            assertionFailure("Unsupported device")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            assertionFailure("Unsupported device")
            return
        }

        self.captureSession = captureSession
    }

    private func relayoutPreviewLayer() {
        self.previewLayer?.frame = self.bounds
        self.overlayLayer.frame = self.bounds

        let overlayPath = UIBezierPath(rect: self.bounds)

        let frameRect = self.getCurrentQRFrameRect()
        let holePath = UIBezierPath(roundedRect: frameRect, cornerRadius: 8)
        overlayPath.append(holePath)
        overlayPath.usesEvenOddFillRule = true

        self.overlayLayer.path = overlayPath.cgPath
        self.qrCodeFrameLayer.frame = frameRect
    }
}

extension QRScannerView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white

        self.setupAudioVideo()
        self.setupPreviewLayer()
    }

    func addSubviews() {
        self.addSubview(self.tipLabel)

        self.addSubview(self.statusStackView)
        self.statusImageViewContainerView.addSubview(self.statusIconView)

        self.addSubview(self.resultButton)
    }

    func makeConstraints() {
        self.tipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.tipBackgroundViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.tipBackgroundViewInsets.right)

            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-self.appearance.tipBackgroundViewInsets.left)
            } else {
                make.bottom.equalToSuperview().offset(-self.appearance.tipBackgroundViewInsets.bottom)
            }
        }

        self.statusIconView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.iconSize)
            make.center.equalToSuperview()
        }

        self.statusImageViewContainerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.iconSize.height)
        }

        self.statusStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(self.appearance.statusTopOffset)
            make.leading.equalToSuperview().offset(self.appearance.statusInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.statusInsets.right)
        }

        self.resultButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.resultButtonInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.resultButtonInsets.right)
            make.height.equalTo(self.appearance.resultButtonHeight)

            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-self.appearance.resultButtonInsets.left)
            } else {
                make.bottom.equalToSuperview().offset(-self.appearance.resultButtonInsets.bottom)
            }
        }
    }
}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let codeObject = self.previewLayer?.transformedMetadataObject(for: readableObject) else {
                return
            }

            guard let stringValue = readableObject.stringValue else {
                return
            }

            if self.getCurrentQRFrameRect().contains(codeObject.bounds) {
                self.delegate?.qrScannerViewCodeRecognized(self, code: stringValue)
            }
        }
    }
}
