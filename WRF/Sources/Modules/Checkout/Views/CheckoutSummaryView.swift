import SnapKit
import UIKit

extension CheckoutSummaryView {
    struct Appearance {
        let mainFont = UIFont.wrfFont(ofSize: 20, weight: .light)
        let mainTextColor = Palette.shared.textPrimary
        let mainEditorLineHeight: CGFloat = 23

        let separatorSize = CGSize(width: 1, height: 15)
        let separatorColor = Palette.shared.strokeSecondary

        let dateLabelInsets = LayoutInsets(top: 15, left: 24, right: 24)
        let guestsLabelInsets = LayoutInsets(left: 15, right: 18)
        let timeLabelInsets = LayoutInsets(left: 24, right: 15)
    }
}

final class CheckoutSummaryView: UIView {
    let appearance: Appearance

    var guestsText: String? {
        didSet {
            self.guestsLabel.attributedText = LineHeightStringMaker.makeString(
                self.guestsText ?? "",
                editorLineHeight: self.appearance.mainEditorLineHeight,
                font: self.appearance.mainFont
            )
        }
    }

    var dateText: String? {
        didSet {
            self.dateLabel.attributedText = LineHeightStringMaker.makeString(
                self.dateText ?? "",
                editorLineHeight: self.appearance.mainEditorLineHeight,
                font: self.appearance.mainFont
            )
        }
    }

    var timeText: String? {
        didSet {
            self.timeLabel.attributedText = LineHeightStringMaker.makeString(
                self.timeText ?? "",
                editorLineHeight: self.appearance.mainEditorLineHeight,
                font: self.appearance.mainFont
            )
        }
    }

    private lazy var guestsLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.mainFont
        label.lineBreakMode = .byTruncatingTail
        label.textColorThemed = self.appearance.mainTextColor
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.mainFont
        label.textColorThemed = self.appearance.mainTextColor
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.mainFont
        label.textColorThemed = self.appearance.mainTextColor
        return label
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.dateLabelInsets.top + self.dateLabel.intrinsicContentSize.height
        )
    }

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
        self.invalidateIntrinsicContentSize()
    }

    // MAKE: Private API

    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColorThemed = self.appearance.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.separatorSize)
        }
        return view
    }
}

extension CheckoutSummaryView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.guestsLabel)
        self.addSubview(self.dateLabel)
        self.addSubview(self.timeLabel)
    }

    func makeConstraints() {
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.appearance.dateLabelInsets.top)
        }

        let leftSeparator = self.makeSeparator()
        self.addSubview(leftSeparator)
        leftSeparator.translatesAutoresizingMaskIntoConstraints = false
        leftSeparator.snp.makeConstraints { make in
            make.trailing.equalTo(self.dateLabel.snp.leading).offset(-self.appearance.dateLabelInsets.left)
            make.centerY.equalTo(self.dateLabel.snp.centerY)
        }

        let rightSeparator = self.makeSeparator()
        self.addSubview(rightSeparator)
        rightSeparator.translatesAutoresizingMaskIntoConstraints = false
        rightSeparator.snp.makeConstraints { make in
            make.leading.equalTo(self.dateLabel.snp.trailing).offset(self.appearance.dateLabelInsets.right)
            make.centerY.equalTo(self.dateLabel.snp.centerY)
        }

        self.guestsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.guestsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.dateLabel.snp.centerY)
            make.trailing.equalTo(leftSeparator.snp.leading).offset(-self.appearance.guestsLabelInsets.right)
            make.leading.greaterThanOrEqualToSuperview().offset(self.appearance.guestsLabelInsets.left)
        }

        self.timeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.dateLabel.snp.centerY)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.timeLabelInsets.right)
            make.leading.equalTo(rightSeparator.snp.trailing).offset(self.appearance.timeLabelInsets.left)
        }
    }
}
