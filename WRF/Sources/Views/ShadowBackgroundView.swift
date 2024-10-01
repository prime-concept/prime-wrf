import SnapKit
import UIKit

extension ShadowBackgroundView {
    struct Appearance {
        var shadowRadius: CGFloat = 2
        var shadowColor = Palette.shared.black.withAlphaComponent(0.5)
        var shadowOffset = CGSize(width: 0, height: 2)

        var borderColor = Palette.shared.black.withAlphaComponent(0.1)
        var borderWidth: CGFloat = 0.5
        var cornerRadius: CGFloat = 8

        var backgroundColor = Palette.shared.backgroundColor0

        var alignmentInsets = UIEdgeInsets.zero
    }
}

final class ShadowBackgroundView: UIView {
    let appearance: Appearance

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var backgroundView = UIView()

    private func setupView() {
        isUserInteractionEnabled = false

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(appearance.alignmentInsets)
        }

        backgroundView.backgroundColorThemed = appearance.backgroundColor

        backgroundView.layer.cornerRadius = appearance.cornerRadius
        backgroundView.layer.borderWidth = appearance.borderWidth
        backgroundView.layer.borderColorThemed = appearance.borderColor

        backgroundView.dropShadowThemed(
            offset: appearance.shadowOffset,
            radius: appearance.shadowRadius,
            color: appearance.shadowColor
        )
    }
}
