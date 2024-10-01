import SnapKit
import UIKit

extension FeedbackTagsView {
    struct Appearance {
        let insets = LayoutInsets(top: 38, left: 26, bottom: 8, right: 26)

        let titleFont = UIFont.wrfFont(ofSize: 18)
        var titleTextColor = UIColor.black
        let titleEditorLineHeight: CGFloat = 21
        let titleInsets = LayoutInsets(bottom: 23)

        let tagLabelInsets = LayoutInsets(left: 20, right: 20)
        let tagHeight: CGFloat = 32
        let lineSpacing: CGFloat = 15
        let itemSpacing: CGFloat = 13
    }
}

final class FeedbackTagsView: UIView {
    let appearance: Appearance

    private let highRatingTags = ["Кухня", "Сервис", "Атмосфера"]
    private lazy var lowRatingTags = self.highRatingTags + ["Интерьер", "Музыку", "Цены"]
    private lazy var tags = self.highRatingTags

    var rating: Int = 5 {
        didSet {
            self.tags = self.rating >= 4 ? self.highRatingTags : self.lowRatingTags
            self.makeTagsView()
        }
    }

    var selectedTags: [String] = []

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.attributedText = LineHeightStringMaker.makeString(
            "Что можно улучшить?",
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont,
            alignment: .center
        )
        label.textColor = self.appearance.titleTextColor
        return label
    }()

    private lazy var tagsContainerView = UIView()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top
                + self.titleLabel.intrinsicContentSize.height
                + self.appearance.insets.bottom
                + self.tagsContainerView.intrinsicContentSize.height
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
        self.makeTagsView()
        self.invalidateIntrinsicContentSize()
    }

    // MARK: - Private API

    private func makeTagsView() {
        self.selectedTags = []

        for subview in self.tagsContainerView.subviews {
            subview.removeFromSuperview()
        }

        // Create and re-layout buttons
        let buttons: [ShadowButton] = self.tags.map { tag in
            let button = ShadowButton()
            button.title = tag
            button.addTarget(self, action: #selector(self.tagSelected), for: .touchUpInside)
            return button
        }

        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.snp.makeConstraints { make in
                let width = button.intrinsicContentSize.width
                    + self.appearance.tagLabelInsets.left
                    + self.appearance.tagLabelInsets.right
                make.width.equalTo(width)
                make.height.equalTo(self.appearance.tagHeight)
            }

            button.setNeedsLayout()
            button.layoutIfNeeded()
        }

        // Greedy iterate through buttons and add them to container
        let fullWidth = self.tagsContainerView.bounds.size.width
        var index = 0
        var currentWidth: CGFloat = 0
        var tagsButtons: [[ShadowButton]] = []
        var currentButtons: [ShadowButton] = []

        while index <= buttons.count {
            if index == buttons.count, !currentButtons.isEmpty {
                tagsButtons.append(currentButtons)
                break
            }

            let buttonWidth = buttons[index].bounds.size.width

            if buttonWidth > fullWidth {
                index += 1
                continue
            }

            if currentWidth + buttonWidth <= fullWidth {
                currentWidth += buttonWidth + self.appearance.itemSpacing
                currentButtons.append(buttons[index])
                index += 1
            } else {
                currentWidth = 0
                tagsButtons.append(currentButtons)
                currentButtons.removeAll()
            }
        }

        var y: CGFloat = 0
        for row in tagsButtons {
            let rowWidth = row
                .map { $0.bounds.width }
                .reduce(CGFloat(row.count - 1) * self.appearance.itemSpacing, +)

            var x = (fullWidth - rowWidth) / 2
            for button in row {
                self.tagsContainerView.addSubview(button)
                let size = button.bounds.size
                button.translatesAutoresizingMaskIntoConstraints = true
                button.frame = CGRect(
                    origin: CGPoint(x: x, y: y),
                    size: size
                )
                x += size.width + self.appearance.itemSpacing
            }
            y += self.appearance.tagHeight + self.appearance.lineSpacing
        }

        self.tagsContainerView.snp.updateConstraints { make in
            make.height.equalTo(y - self.appearance.lineSpacing)
        }
    }

    @objc
    private func tagSelected(_ tag: ShadowButton) {
        tag.isSelected.toggle()
        let tagTitle = tag.title ?? ""
        if tag.isSelected {
            self.selectedTags.append(tagTitle)
        } else {
            if let index = self.selectedTags.firstIndex(of: tagTitle) {
                self.selectedTags.remove(at: index)
            }
        }
    }
}

extension FeedbackTagsView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.tagsContainerView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(self.appearance.insets.top)
        }

        self.tagsContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.tagsContainerView.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.titleInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}
