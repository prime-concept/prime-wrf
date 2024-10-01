import Foundation
import UIKit

extension LinkLabel {
    struct Appearance {
        var linkFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        var underlineColor = UIColor.black
        let editorLineHeight: CGFloat = 16
    }
}

final class LinkLabel: UILabel {
    private let appearance: Appearance

    private var links: [String: URL?] = [:]
    private var isInitialized = false

    var onLinkClick: ((URL) -> Void)?

    init(appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: .zero)

        self.numberOfLines = 0
        self.isUserInteractionEnabled = true
        self.lineBreakMode = .byWordWrapping

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.labelClicked))
        self.addGestureRecognizer(tapGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // set link attributes
        if !self.isInitialized {
            self.isInitialized = true

            guard let text = self.text else {
                return
            }
            self.attributedText = self.makeAttributedString(from: text)
        }
    }

    // MARK: - Public API

    func addLink(_ link: URL?, for string: String) {
        self.links[string] = link
    }

    // MARK: - Private API

    @objc
    private func labelClicked(_ sender: UITapGestureRecognizer) {
        guard let text = self.text else {
            return
        }
        let mutableString = NSMutableAttributedString(string: text).mutableString
        for (text, link) in self.links {
            let range = mutableString.range(of: text)
            if self.didTapLink(gesture: sender, targetRange: range) {
                guard let link = link else {
                    return
                }
                self.onLinkClick?(link)
                break
            }
        }
    }

    private func makeAttributedString(from string: String) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(string: string)
        let paragraphStyle = NSMutableParagraphStyle()
        let lineSpacing = self.appearance.editorLineHeight - self.font.lineHeight
        paragraphStyle.lineSpacing = lineSpacing
        mutableString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: mutableString.length)
        )
        for (string, _) in self.links {
            mutableString.addAttributes(
                self.makeLinkAttributes(),
                range: mutableString.mutableString.range(of: string)
            )
        }
        return mutableString
    }

    private func didTapLink(gesture: UITapGestureRecognizer, targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: self.attributedText ?? NSAttributedString())

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        let labelSize = self.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = gesture.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        return NSLocationInRange(indexOfCharacter, targetRange)
    }

    private func makeLinkAttributes() -> [NSAttributedString.Key: Any] {
        return [
            .font: self.appearance.linkFont,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: self.appearance.underlineColor
        ]
    }
}
