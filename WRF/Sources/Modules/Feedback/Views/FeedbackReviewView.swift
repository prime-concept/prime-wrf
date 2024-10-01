import SnapKit
import UIKit

extension FeedbackReviewView {
    struct Appearance {
        let textViewInsets = LayoutInsets(top: 28, left: 12, bottom: 0, right: 15)
        let backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        let cornerRadius: CGFloat = 10
        let textFont = UIFont.wrfFont(ofSize: 15, weight: .light)
    }
}

final class FeedbackReviewView: UIView {
    let appearance: Appearance

    private(set) lazy var textView: GrowingTextView = {
        let textView = GrowingTextView()
        textView.backgroundColor = self.appearance.backgroundColor
        textView.clipsToBounds = true
        textView.layer.cornerRadius = self.appearance.cornerRadius
        textView.font = self.appearance.textFont
        textView.placeholder = "Расскажите подробнее"
        return textView
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.textViewInsets.top
                + self.textView.intrinsicContentSize.height
                + self.appearance.textViewInsets.bottom
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
}

extension FeedbackReviewView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.textView)
    }

    func makeConstraints() {
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.textViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.textViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.textViewInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.textViewInsets.bottom)
        }
    }
}
