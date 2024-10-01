import UIKit

class CheckboxControl: UIControl {
    struct Appearance {
        let cornerRadius: CGFloat = 3
        var selectedBackgroundColor = UIColor.black
        let size = CGSize(width: 20, height: 20)
    }

    private var appearance: Appearance

    override var intrinsicContentSize: CGSize {
        return self.appearance.size
    }

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.layer.contents = #imageLiteral(resourceName: "checkbox-checked-state").cgImage
            } else {
                self.layer.contents = nil
            }
        }
    }

    var onChange: ((Bool) -> Void)?

    init(
        frame: CGRect = .zero,
        isSelected: Bool = true,
        appearance: Appearance = ApplicationAppearance.appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.isSelected = isSelected

        self.backgroundColor = self.appearance.selectedBackgroundColor
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.isSelected.toggle()
        self.onChange?(self.isSelected)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin = 10.0
        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }
}
