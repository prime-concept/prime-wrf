import UIKit

extension MapFilterItemView {
    struct Appearance {
        var itemTextColor = UIColor.black
        let itemFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        let itemEditorLineHeight: CGFloat = 17
    }
}

final class MapFilterItemView: UIView {
    let appearance: Appearance

    var title: String? {
        didSet {
            self.itemLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.itemEditorLineHeight,
                font: self.appearance.itemFont
            )
        }
    }

    private lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.itemTextColor
        label.font = self.appearance.itemFont
        return label
    }()

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
}

extension MapFilterItemView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.itemLabel)
    }

    func makeConstraints() {
        self.itemLabel.translatesAutoresizingMaskIntoConstraints = false
        self.itemLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
    }
}
