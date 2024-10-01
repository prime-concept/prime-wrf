import UIKit

extension QRScanView {
    struct Appearance {
        let iconSize = CGSize(width: 17, height: 17)
        let iconInsets = LayoutInsets(right: 14)

        let backgroundColor = UIColor.black

        let labelFont = UIFont.wrfFont(ofSize: 14)
        let labelTextColor = UIColor.white
        let labelLineHeight: CGFloat = 16

        let labelInsets = LayoutInsets(left: 15)
    }
}

final class QRScanView: UIView {
    let appearance: Appearance

    var onQRTap: (() -> Void)?

    private lazy var iconView: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "qr-scan-icon"))
        image.contentMode = .scaleAspectFit
        return image
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = self.appearance.labelFont
        label.textColor = self.appearance.labelTextColor
        label.attributedText = LineHeightStringMaker.makeString(
            "Сканировать QR-код",
            editorLineHeight: self.appearance.labelLineHeight,
            font: self.appearance.labelFont
        )
        return label
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.setHightlightedState()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.setNormalState()
        self.onQRTap?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.setNormalState()
    }

    // MARK: - Private

    private func setHightlightedState() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        )
    }

     private func setNormalState() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.transform = .identity
            }
        )
    }
}

extension QRScanView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.label)
        self.addSubview(self.iconView)
    }

    func makeConstraints() {
        self.label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.labelInsets.left)
            make.centerY.equalToSuperview()
        }

        self.iconView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.iconInsets.right)
            make.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.iconSize)
        }
    }
}
