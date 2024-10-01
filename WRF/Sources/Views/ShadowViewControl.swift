import SnapKit
import UIKit

class ShadowViewControl: UIControl, ProgrammaticallyDesignable {
    struct Appearance {
        let cornerRadius: CGFloat = 8
        var selectedBackgroundColor = Palette.shared.buttonAccent
    }

    private lazy var shadowBackgroundView = ShadowBackgroundView()

    private var appearance: Appearance

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var isSelected: Bool {
        didSet {
            self.shadowBackgroundView.isHidden = self.isSelected
            self.backgroundColorThemed = self.isSelected ? appearance.selectedBackgroundColor : Palette.shared.clear
            self.clipsToBounds = self.isSelected
            self.layer.cornerRadius = appearance.cornerRadius
        }
    }

    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1.0 : 0.4
        }
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

    // MARK: - ProgrammaticallyDesignable

    func setupView() {
        self.isUserInteractionEnabled = true
    }

    func addSubviews() {
        self.addSubview(self.shadowBackgroundView)
    }

    func makeConstraints() {
        self.shadowBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
