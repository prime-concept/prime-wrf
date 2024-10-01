import UIKit

extension ShareButtonView {
    struct Appearance {
        let shareTextColor = UIColor.white
        let shareTextFont = UIFont.wrfFont(ofSize: 18)
        let shareEditorLineHeight: CGFloat = 21

        let shareBorderWidth: CGFloat = 1
        let shareCornerRadius: CGFloat = 8
        let shareBorderColor = UIColor.white.withAlphaComponent(0.5)

        let stackSpacing: CGFloat = 15
        let stackInsets = LayoutInsets(top: 10, left: 25, bottom: 10, right: 25)
    }
}

final class ShareButtonView: UIView {
    let appearance: Appearance

    private lazy var shareIconImageView: UIImageView = {
        let image = #imageLiteral(resourceName: "discount-share").withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        return imageView
    }()

    private lazy var shareLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.shareTextFont
        label.attributedText = LineHeightStringMaker.makeString(
            "EXgr54",
            editorLineHeight: self.appearance.shareEditorLineHeight,
            font: self.appearance.shareTextFont
        )
        label.textColor = self.appearance.shareTextColor
        return label
    }()

    private lazy var shareStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.shareIconImageView, self.shareLabel])
        stack.spacing = self.appearance.stackSpacing
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()

    private lazy var shareContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = self.appearance.shareCornerRadius
        view.layer.borderWidth = self.appearance.shareBorderWidth
        view.layer.borderColor = self.appearance.shareBorderColor.cgColor
        return view
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

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension ShareButtonView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.shareContainerView)
        self.shareContainerView.addSubview(self.shareStackView)
    }

    func makeConstraints() {
        self.shareContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.shareContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.shareStackView.translatesAutoresizingMaskIntoConstraints = false
        self.shareStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.stackInsets.left)
            make.top.equalToSuperview().offset(self.appearance.stackInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.stackInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.stackInsets.right)
        }
    }
}
