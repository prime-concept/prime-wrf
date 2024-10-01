import SnapKit
import UIKit

extension RestaurantBookingDayButton {
    struct Appearance {
        let secondaryFont = UIFont.wrfFont(ofSize: 10, weight: .medium)
        var secondaryTextColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        var secondarySelectedTextColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let secondaryEditorLineHeight: CGFloat = 11

        let mainFont = UIFont.wrfFont(ofSize: 16)
        var mainTextColor = UIColor.black
        var mainSelectedTextColor = UIColor.white
        let mainEditorLineHeight: CGFloat = 18

        let mainLabelInsets = LayoutInsets(top: 1, bottom: 1)
        var selectedBackgroundColor = Palette.shared.black
    }
}

final class RestaurantBookingDayButton: ShadowViewControl {
    let appearance: Appearance

    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.mainFont
        label.textColor = self.appearance.mainTextColor
        return label
    }()

    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.secondaryFont
        label.textColor = self.appearance.secondaryTextColor
        return label
    }()

    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.secondaryFont
        label.textColor = self.appearance.secondaryTextColor
        return label
    }()

    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            self.mainLabel.textColor = newValue
                ? self.appearance.mainSelectedTextColor
                : self.appearance.mainTextColor
            self.topLabel.textColor = newValue
                ? self.appearance.secondarySelectedTextColor
                : self.appearance.secondaryTextColor
            self.bottomLabel.textColor = newValue
                ? self.appearance.secondarySelectedTextColor
                : self.appearance.secondaryTextColor
            super.isSelected = newValue
        }
    }

    var day: String? {
        didSet {
            self.mainLabel.attributedText = LineHeightStringMaker.makeString(
                self.day ?? "",
                editorLineHeight: self.appearance.mainEditorLineHeight,
                font: self.appearance.mainFont
            )
        }
    }

    var dayOfWeek: String? {
        didSet {
            self.topLabel.attributedText = LineHeightStringMaker.makeString(
                self.dayOfWeek ?? "",
                editorLineHeight: self.appearance.secondaryEditorLineHeight,
                font: self.appearance.secondaryFont
            )
        }
    }

    var relativeDay: String? {
        didSet {
            self.bottomLabel.attributedText = LineHeightStringMaker.makeString(
                self.relativeDay ?? "",
                editorLineHeight: self.appearance.secondaryEditorLineHeight,
                font: self.appearance.secondaryFont
            )
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
        self.appearance = appearance

        var superAppearance = ShadowViewControl.Appearance()
        superAppearance.selectedBackgroundColor = self.appearance.selectedBackgroundColor
        super.init(frame: frame, appearance: superAppearance)
    }

    // MARK: - ProgrammaticallyDesignable

    override func addSubviews() {
        super.addSubviews()

        self.addSubview(self.topLabel)
        self.addSubview(self.mainLabel)
        self.addSubview(self.bottomLabel)
    }

    override func makeConstraints() {
        super.makeConstraints()

        self.mainLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mainLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.topLabel.translatesAutoresizingMaskIntoConstraints = false
        self.topLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.mainLabel.snp.top).offset(-self.appearance.mainLabelInsets.top)
            make.centerX.equalToSuperview()
        }

        self.bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(self.mainLabel.snp.bottom).offset(self.appearance.mainLabelInsets.bottom)
            make.centerX.equalToSuperview()
        }
    }
}
