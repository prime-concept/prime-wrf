import SnapKit
import UIKit

extension FeedbackAgreementView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        var titleTextColor = UIColor.black
        let titleEditorLineHeight: CGFloat = 17
        let titleInsets = LayoutInsets(top: 1, left: 22, right: 15)

        let checkboxInsets = LayoutInsets(top: 12, bottom: 0, right: 27)
    }
}

final class FeedbackAgreementView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.attributedText = LineHeightStringMaker.makeString(
            "Опубликовать отзыв",
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont,
            alignment: .center
        )
        label.textColor = self.appearance.titleTextColor
        return label
    }()

    private(set) lazy var checkboxControl = CheckboxControl()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.checkboxInsets.top
                + self.checkboxControl.intrinsicContentSize.height
                + self.appearance.checkboxInsets.bottom
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
        self.invalidateIntrinsicContentSize()
    }
}

extension FeedbackAgreementView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.checkboxControl)
    }

    func makeConstraints() {
        self.checkboxControl.translatesAutoresizingMaskIntoConstraints = false
        self.checkboxControl.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.checkboxInsets.right)
            make.top.equalToSuperview().offset(self.appearance.checkboxInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.checkboxInsets.bottom)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.checkboxControl).offset(self.appearance.titleInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
            make.trailing
                .lessThanOrEqualTo(self.checkboxControl.snp.leading)
                .offset(-self.appearance.titleInsets.right)
        }
    }
}
