import SnapKit
import UIKit

typealias ButtonData = (title: String, url: String)

extension RestaurantDescriptionView {
    struct Appearance {
        let font = UIFont.wrfFont(ofSize: 15)
        var brightTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        var darkTextColor = UIColor.white
        let editorLineHeight: CGFloat = 22
        var insets = LayoutInsets(top: 20, left: 15, bottom: 0, right: 15)
        let expandArrowButtonInsets = LayoutInsets(top: 15, bottom: 10)
        let expandButtonTitleInsets = LayoutInsets(top: 23, left: 15, bottom: 5, right: -15)
        let expandButtonSize = CGSize(width: 18, height: 10)
        let expandButtonHeight: CGFloat = 39.0
        let infoButtonInsets = LayoutInsets(top: 15, left: 15, bottom: 15, right: 20)
        let infoButtonHeight: CGFloat = 41
        let expandButtonRadius: CGFloat = 6.0
        let brightLayerColors = [
            UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        ]
        let darkLayerColors = [
            UIColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 0.0).cgColor,
            UIColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 1.0).cgColor
        ]
        let expandButtonFont = UIFont.wrfFont(ofSize: 14.0)
    }
}

final class RestaurantDescriptionView: UIView {
    private var numberOfVisibleLines = 4

    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.attributedText = LineHeightStringMaker.makeString(
            self.text ?? "",
            editorLineHeight: self.appearance.editorLineHeight,
            font: self.appearance.font
        )
        label.textColor = PGCMain.shared.featureFlags.map.showMapSearch
            ? appearance.darkTextColor
            : appearance.brightTextColor

        label.numberOfLines = 0
        return label
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = PGCMain.shared.featureFlags.map.showMapSearch
            ? appearance.darkLayerColors
            : appearance.brightLayerColors

        layer.locations = [0.45, 1]
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
        )
        return layer
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private lazy var expandButton: UIButton = {
        if PGCMain.shared.featureFlags.map.showMapSearch {
            let button = UIButton()
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = appearance.expandButtonFont
            button.layer.cornerRadius = appearance.expandButtonRadius
            button.clipsToBounds = true
            button.setTitle("Подробнее", for: .normal)
            button.addTarget(self, action: #selector(onExpandButtonTap), for: .touchUpInside)
            return button
        } else {
            let button = UIButton()
            button.setImage(UIImage(named: "event-expand-icon"), for: .normal)
            button.addTarget(self, action: #selector(self.onExpandButtonTap), for: .touchUpInside)
            return button
        }
    }()

    private lazy var infoButton: ShadowButton = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = UIFont.wrfFont(ofSize: 14)
        appearance.mainEditorLineHeight = 16
        let button = ShadowButton(appearance: appearance)
        button.addTarget(self, action: #selector(self.onInfoButtonTap), for: .touchUpInside)
        return button
    }()

    var text: String? {
        didSet {
            self.textLabel.attributedText = LineHeightStringMaker.makeString(
                self.text ?? "",
                editorLineHeight: self.appearance.editorLineHeight,
                font: self.appearance.font
            )
            self.updateExpanded()
            self.updateLayout()
        }
    }

    var buttonData: ButtonData? {
        didSet {
            self.infoButton.title = self.buttonData?.title
        }
    }

    var isAlwaysExpanded = false {
        didSet {
            self.isExpanded = true
        }
    }

    var isExpandButtonAvailable: Bool = false

    private(set) var isExpanded = false {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.gradientLayer.isHidden = self.isExpanded || self.isAlwaysExpanded

            self.updateLayout()
        }
    }

    private var numberOfLinesInTextLabel: Int {
        let maxSize = CGSize(
            width: self.containerView.frame.width,
            height: CGFloat.infinity
        )
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: self.appearance.font],
            context: nil
        )
        let charSize = self.appearance.font.lineHeight
        return Int(ceil(textSize.height / charSize))
    }

    private var isInfoButtonHidden: Bool {
        return self.buttonData == nil || !self.isExpanded
    }

    override var intrinsicContentSize: CGSize {
        let fullHeight = CGFloat(self.numberOfLinesInTextLabel) * self.appearance.editorLineHeight

        let fullInsetsHeight = self.isInfoButtonHidden
            ? 0
            : (self.appearance.expandButtonHeight + self.appearance.expandButtonTitleInsets.top +  self.appearance.expandButtonTitleInsets.bottom)

        let collapsedHeight = CGFloat(self.numberOfVisibleLines) * self.appearance.editorLineHeight

        let collapsedInsetsHeight = self.appearance.expandButtonTitleInsets.top + self.appearance.expandButtonHeight

        let height = (self.isExpanded || self.isAlwaysExpanded)
            ? (fullHeight + fullInsetsHeight)
            : (collapsedHeight + collapsedInsetsHeight)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top + self.appearance.insets.bottom + height + self.appearance.expandButtonTitleInsets.bottom
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = ApplicationAppearance.appearance()
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
        DispatchQueue.main.async {
            self.invalidateIntrinsicContentSize()
        }

        if self.gradientLayer.superlayer == nil {
            // First time re-layout
            self.containerView.layer.insertSublayer(self.gradientLayer, above: self.textLabel.layer)
            self.updateExpanded()
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        self.gradientLayer.frame = self.containerView.bounds

        CATransaction.commit()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if self.isAlwaysExpanded {
            return
        }

        if self.numberOfLinesInTextLabel > self.numberOfVisibleLines {
            self.isExpanded.toggle()
        }
    }

    private func updateExpanded() {
        let isExpanded = self.numberOfLinesInTextLabel <= self.numberOfVisibleLines
        if isExpanded != self.isExpanded {
            self.isExpanded = isExpanded || self.isAlwaysExpanded
        }
    }

    private func updateLayout() {
        guard self.isExpandButtonAvailable else {
            return
        }

        self.expandButton.isHidden = self.isExpanded && !PGCMain.shared.featureFlags.map.showMapSearch
        self.infoButton.isHidden = self.isInfoButtonHidden

        if PGCMain.shared.featureFlags.map.showMapSearch {
            expandButton.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(appearance.expandButtonTitleInsets.left)
                make.trailing.equalToSuperview().offset(appearance.expandButtonTitleInsets.right)
                make.top.equalTo(containerView.snp.bottom).offset(appearance.expandButtonTitleInsets.top)
                make.bottom.equalToSuperview().inset(appearance.expandButtonTitleInsets.bottom)
                make.height.equalTo(appearance.expandButtonHeight)
            }
        }

        if self.isExpanded {
            if !PGCMain.shared.featureFlags.map.showMapSearch {
                self.expandButton.snp.removeConstraints()

                self.containerView.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(self.appearance.insets.top)
                    make.leading.equalToSuperview().offset(self.appearance.insets.left)
                    make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
                    if self.isInfoButtonHidden {
                        make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
                    }
                }
            }

            if self.isInfoButtonHidden == false {
                self.infoButton.snp.makeConstraints { make in
                    make.top.equalTo(self.containerView.snp.bottom)
                        .offset(self.appearance.infoButtonInsets.top)
                    make.height.equalTo(self.appearance.infoButtonHeight)
                    make.leading.equalToSuperview()
                        .offset(self.appearance.infoButtonInsets.left)
                    make.trailing.equalToSuperview()
                        .offset(-self.appearance.infoButtonInsets.right)
                    make.bottom.equalToSuperview()
                        .offset(-self.appearance.infoButtonInsets.bottom)
                }
            }
        } else {
            self.infoButton.snp.removeConstraints()

            self.containerView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(self.appearance.insets.top)
                make.leading.equalToSuperview().offset(self.appearance.insets.left)
                make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            }

            if !PGCMain.shared.featureFlags.map.showMapSearch {
                expandButton.snp.remakeConstraints { make in
                    make.top.equalTo(self.containerView.snp.bottom)
                        .offset(self.appearance.expandArrowButtonInsets.top)
                    make.size.equalTo(self.appearance.expandButtonSize)
                    make.centerX.equalToSuperview()
                    make.bottom.equalToSuperview()
                        .offset(-self.appearance.expandArrowButtonInsets.bottom)
                }
            }
        }
    }

    @objc
    private func onExpandButtonTap() {
        if self.numberOfLinesInTextLabel > self.numberOfVisibleLines {
            self.isExpanded.toggle()
        }
    }

    @objc
    private func onInfoButtonTap() {
        guard let urlString = self.buttonData?.url else {
            return
        }

        let urlWithPrefix = urlString.hasPrefix("http") ? urlString : "http://\(urlString)"

        guard let url = URL(string: urlWithPrefix) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func setCustomNumberOfVisibleLines(number: Int) {
        self.numberOfVisibleLines = number
    }
}

extension RestaurantDescriptionView: ProgrammaticallyDesignable {
    func setupView() {
        self.isUserInteractionEnabled = true
    }

    func addSubviews() {
        self.containerView.addSubview(self.textLabel)
        self.addSubview(self.containerView)
        self.addSubview(self.expandButton)
        self.addSubview(self.infoButton)
    }

    func makeConstraints() {
        self.textLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        if self.isExpandButtonAvailable == false {
            self.containerView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(self.appearance.insets.top)
                make.leading.equalToSuperview().offset(self.appearance.insets.left)
                make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
                make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
            }
        }
    }
}
