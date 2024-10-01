import UIKit

enum LineHeightStringMaker {
    /// Return attributed string with lineSpacing from Figma / Sketch
    static func makeString(_ text: String, lineSpacing: CGFloat) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing

        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttributes(
            [.paragraphStyle: paragraphStyle],
            range: range
        )

        return attributedText
    }

    /// Return attributed string with lineHeight from Figma / Sketch
    static func makeString(
        _ text: String,
        editorLineHeight: CGFloat,
        font: UIFont,
        alignment: NSTextAlignment = .natural,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        let lineSpacing = editorLineHeight - font.lineHeight
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode

        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttributes(
            [.paragraphStyle: paragraphStyle],
            range: range
        )

        return attributedText
    }
}
