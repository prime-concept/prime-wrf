import SnapKit
import UIKit

extension RestaurantBookingResultView {
    struct Appearance {
        let iconSize = CGSize(width: 55, height: 55)

        let inset: CGFloat = 15

        var textColor = UIColor.black

        var mainTextColor = Palette.shared.textPrimary

        let titleFont = UIFont.wrfFont(ofSize: 13, weight: .medium)
        let titleEditorLineHeight: CGFloat = 18

        let subtitleFont = UIFont.wrfFont(ofSize: 13)

        let spacing: CGFloat = 10
        let imageSpacing: CGFloat = 15
        let titleSpacing: CGFloat = 5
        let subtitleSpacing: CGFloat = 18

        let buttonFont = UIFont.wrfFont(ofSize: 14)
        let retryButtonEditorLineHeight: CGFloat = 16
        let buttonHeight: CGFloat = 39
    }
}

final class RestaurantBookingResultView: UIView {
    let appearance: Appearance

    private lazy var imageView = UIImageView()

    private lazy var imageViewContainerView = UIView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.textColor
        label.numberOfLines = 1
		self.titleHeightConsraint = label.make(.height, .equal, 0)
		self.titleHeightConsraint?.isActive = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleFont
        label.textColor = self.appearance.textColor
        label.numberOfLines = 0

		self.subtitleHeightConsraint = label.make(.height, .equal, 0)
		self.subtitleHeightConsraint?.isActive = false
		
        return label
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(
            arrangedSubviews: [
                self.imageViewContainerView,
                self.titleLabel,
                self.subtitleLabel,
                self.doneButton,
                self.retryButton
            ]
        )
        view.axis = .vertical
        view.spacing = self.appearance.spacing
        view.setCustomSpacing(self.appearance.imageSpacing, after: self.imageViewContainerView)
        view.setCustomSpacing(self.appearance.titleSpacing, after: self.titleLabel)
        view.setCustomSpacing(self.appearance.subtitleSpacing, after: self.subtitleLabel)
        return view
    }()

    private lazy var retryButton: UIControl = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
		appearance.mainTextColor = self.appearance.mainTextColor ?? appearance.mainTextColor
        appearance.mainFont = self.appearance.buttonFont
        appearance.mainEditorLineHeight = self.appearance.retryButtonEditorLineHeight
        let button = ShadowButton(appearance: appearance)
        button.title = "Попробовать ещё раз"
        button.addTarget(self, action: #selector(self.retryClicked), for: .touchUpInside)
        return button
    }()

    private lazy var doneButton: ShadowButton = {
        var appearance = ShadowButton.Appearance()
		appearance.mainTextColor = self.appearance.mainTextColor ?? appearance.mainTextColor
        appearance.mainFont = self.appearance.buttonFont
        let button = ShadowButton(appearance: appearance)
        button.title = "Завершить"
        button.addTarget(self, action: #selector(self.doneClicked), for: .touchUpInside)
        return button
    }()

    var state: State? {
        didSet {
            self.imageView.image = self.state?.image ?? UIImage()
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.state?.text.0 ?? "",
                editorLineHeight: self.appearance.titleEditorLineHeight,
                font: self.appearance.titleFont,
                alignment: .center
            )
            self.subtitleLabel.attributedText = LineHeightStringMaker.makeString(
                self.state?.text.1 ?? "",
                editorLineHeight: self.appearance.titleEditorLineHeight,
                font: self.appearance.subtitleFont,
                alignment: .center
            )
            self.retryButton.isHidden = self.state == .success
        }
    }

    var onRetry: (() -> Void)?
    var onDone: (() -> Void)?

	override func layoutSubviews() {
		super.layoutSubviews()

		self.layoutTitleLabel()
		self.layoutSubtitleLabel()
	}

	private var titleHeightConsraint: NSLayoutConstraint?
	private var subtitleHeightConsraint: NSLayoutConstraint?

	private func layoutTitleLabel() {
		let maxSize = CGSize(width: self.titleLabel.bounds.width, height: CGFloat.greatestFiniteMagnitude)
		let maxHeight = self.titleLabel.sizeThatFits(maxSize)

		guard let labelHeightConstraint = self.titleHeightConsraint, labelHeightConstraint.constant != maxHeight.height else {
			return
		}
		labelHeightConstraint.isActive = true
		labelHeightConstraint.constant = maxHeight.height
	}

	private func layoutSubtitleLabel() {
		let maxSize = CGSize(width: self.subtitleLabel.bounds.width, height: CGFloat.greatestFiniteMagnitude)
		let maxHeight = self.subtitleLabel.sizeThatFits(maxSize)

		guard let labelHeightConstraint = self.subtitleHeightConsraint, labelHeightConstraint.constant != maxHeight.height else {
			return
		}
		labelHeightConstraint.isActive = true
		labelHeightConstraint.constant = maxHeight.height
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

    @objc
    private func retryClicked() {
        self.onRetry?()
    }

    @objc
    private func doneClicked() {
        self.onDone?()
    }

    enum State: Equatable {
        case success
        case error(text: String?)

        var image: UIImage {
            switch self {
            case .success:
                return #imageLiteral(resourceName: "booking-result-waiting")
            case .error:
                return #imageLiteral(resourceName: "booking-result-error")
            }
        }

        var text: (String?, String?) {
            switch self {
            case .success:
                return (
                    "Ожидайте подтверждения" ,
                    "Заявка на бронирование отправлена в ресторан.\nОтвет придет в Push-сообщении или SMS."
                )
            case .error(let optionalText):
                if let text = optionalText, text.isEmpty == false {
                    return (nil, text)
                }
                return (nil, "Что-то пошло не так. Проверьте подключение к интернету и попробуйте еще раз")
            }
        }
    }
}

extension RestaurantBookingResultView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.stackView)
        self.imageViewContainerView.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.retryButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.buttonHeight)
        }

        self.doneButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.buttonHeight)
        }

        self.imageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.iconSize)
            make.center.equalToSuperview()
        }

        self.imageViewContainerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.iconSize.height)
        }

        self.stackView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview().inset(self.appearance.inset)
            make.bottom.equalToSuperview()
        }
    }
}
