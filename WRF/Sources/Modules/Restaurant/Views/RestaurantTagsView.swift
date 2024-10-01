import SnapKit
import TagListView
import UIKit

extension RestaurantTagsView {
    struct Appearance {
        let insets = LayoutInsets(top: 12, left: 15, bottom: 0, right: 15)

        let tagCornerRadius: CGFloat = 3
        var tagBackgroundColor = UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 1)
        var tagTextColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        let tagFont = UIFont.wrfFont(ofSize: 14, weight: .semibold)

        let tagMargin = UIOffset(horizontal: 5, vertical: 5)
        let tagPadding = UIOffset(horizontal: 8, vertical: 5)
    }
}

final class RestaurantTagsView: UIView {
    let appearance: Appearance

    private lazy var tagsView: TagListView = {
        let view = TagListView()
        view.alignment = .left
        view.borderColor = .clear
        view.borderWidth = 0

        view.cornerRadius = self.appearance.tagCornerRadius
        view.tagBackgroundColor = self.appearance.tagBackgroundColor
        view.textColor = self.appearance.tagTextColor

        view.textFont = self.appearance.tagFont
        view.isUserInteractionEnabled = false

        // Space between tags
        view.marginX = self.appearance.tagMargin.horizontal
        view.marginY = self.appearance.tagMargin.vertical
        // Space between text and tag background view
        view.paddingX = self.appearance.tagPadding.horizontal
        view.paddingY = self.appearance.tagPadding.vertical

        return view
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.tagsView.bounds.height
        )
    }

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
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

    func update(tags: [String]) {
        self.tagsView.removeAllTags()
        self.tagsView.addTags(tags)
    }
}

extension RestaurantTagsView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.tagsView)
    }

    func makeConstraints() {
        self.tagsView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}
