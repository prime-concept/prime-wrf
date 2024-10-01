import SnapKit
import UIKit

final class ProfileFaqTableViewCell: UITableViewCell, Reusable {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        var titleColor = Palette.shared.textPrimary
        let titleEditorLineHeight: CGFloat = 17
        let titleLeftOffset: CGFloat = 15
    }

    private let appearance: Appearance = ApplicationAppearance.appearance()

    var title: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: appearance.titleEditorLineHeight,
                font: appearance.titleFont
            )
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = appearance.titleFont
        label.textColorThemed = appearance.titleColor
        label.numberOfLines = 2
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.titleLabel.superview == nil {
            self.setupView()
        }
    }

    // MARK: - Private API

    private func setupView() {
        self.backgroundColor = .clear
        self.accessoryType = .disclosureIndicator

        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(appearance.titleLeftOffset)
            make.trailing.centerY.equalToSuperview()
        }
    }
}
