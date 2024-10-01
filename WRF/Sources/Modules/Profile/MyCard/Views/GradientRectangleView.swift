import UIKit

final class GradientRectangleView: UIView {
    struct Appearance: Codable {
        var gradientColors = [
            Palette.shared.white,
            Palette.shared.clear
        ]
    }

    let appearance: Appearance

    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        return gradientLayer
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Theme.shared.gradientRectangleViewAppearance) {
        self.appearance = appearance

        super.init(frame: frame)
        setupGradientLayer()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGradientLayer() {
        alpha = 0.05
        gradientLayer.colorsThemed = appearance.gradientColors
        layer.addSublayer(gradientLayer)
        setMaskLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func setMaskLayer() {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.height))
        path.close()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
