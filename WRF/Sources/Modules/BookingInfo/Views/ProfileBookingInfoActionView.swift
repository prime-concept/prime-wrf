import UIKit

protocol ProfileBookingInfoActionViewDelegate: AnyObject {
    func profileBookingInfoViewDidClickMenu(_ view: ProfileBookingInfoActionView)
    func profileBookingInfoViewDidClickFeedback(_ view: ProfileBookingInfoActionView)
    func profileBookingInfoViewDidClickCancel(_ view: ProfileBookingInfoActionView)
}

extension ProfileBookingInfoActionView {
    struct Appearance {
        var insets = LayoutInsets(top: 10, bottom: 10)

        let buttonTitleFont = UIFont.wrfFont(ofSize: 14)
        let buttonTitleTextColor = Palette.shared.textPrimary
        let separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        let height: CGFloat = 40
        let heightWithCancel: CGFloat = 80

        let cancelButtonBackgroundColor = UIColor(red: 0.971, green: 0.194, blue: 0.194, alpha: 1)

        let stackInsets = LayoutInsets(left: 15, right: 15)
        let stackSpacing: CGFloat = 10
        let horizontalStackSpacing: CGFloat = 5

		let cancelIconSize = CGSize(width: 20, height: 20)
		let cancelMessageFont = UIFont.wrfFont(ofSize: 12, weight: .light)
		let cancelMessageTextColor = UIColor.black
    }
}

final class ProfileBookingInfoActionView: UIView {
    let appearance: Appearance

    var isCancelEnabled: Bool = false {
        didSet {
			self.updateCancelVisibility()
        }
    }
    
    var cancelButtonTitle: String = "" {
        didSet {
            self.updateCancelTitle()
        }
    }

	var isCancelBlocked: Bool = false {
		didSet {
			self.updateCancelVisibility()
		}
	}

	private func updateCancelVisibility() {
		self.cancelButton.isHidden = true
		self.cancelStub.isHidden = true

		guard self.isCancelEnabled else {
			return
		}

		self.cancelButton.isHidden = self.isCancelBlocked
		self.cancelStub.isHidden = !self.isCancelBlocked
	}

    private func updateCancelTitle() {
        self.cancelButton.set(title: self.cancelButtonTitle)
    }

    weak var delegate: ProfileBookingInfoActionViewDelegate?

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.insets.top
                + (self.isCancelEnabled ? self.appearance.heightWithCancel : self.appearance.height)
                + self.appearance.insets.bottom
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: height
        )
    }

    private(set) lazy var menuButton: ShadowButton = {
        var appearance = ShadowButton.Appearance()
        appearance.mainFont = self.appearance.buttonTitleFont
        appearance.mainTextColor = self.appearance.buttonTitleTextColor
        let button = ShadowButton(appearance: appearance)
        button.title = "Меню"
        button.addTarget(self, action: #selector(self.menuButtonClicked), for: .touchUpInside)
        return button
    }()

    private(set) lazy var feedbackButton: ShadowButton = {
        var appearance = ShadowButton.Appearance()
        appearance.mainFont = self.appearance.buttonTitleFont
        appearance.mainTextColor = self.appearance.buttonTitleTextColor
        let button = ShadowButton(appearance: appearance)
        button.title = "Оставить отзыв"
        button.addTarget(self, action: #selector(self.feedbackButtonClicked), for: .touchUpInside)
        return button
    }()

    private(set) lazy var cancelButton: ActionButton = {
        let button = ActionButton(
            title: "Отменить бронь",
            backgroundColor: self.appearance.cancelButtonBackgroundColor
        )
        button.addTarget(self, action: #selector(self.cancelButtonClicked), for: .touchUpInside)
        return button
    }()

	private(set) lazy var cancelStub: UIView = {
		let view = UIView()
		let imageView = UIImageView(image: UIImage.init(named: "info"))
		let label = UILabel()
		label.text = "Для отмены бронирования свяжитесь с рестораном"
		label.font = self.appearance.cancelMessageFont
		label.textColor = self.appearance.cancelMessageTextColor
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping

		view.addSubview(imageView)
		view.addSubview(label)

		imageView.snp.makeConstraints { make in
			make.size.equalTo(self.appearance.cancelIconSize)
			make.leading.equalToSuperview().inset(2)
			make.centerY.equalToSuperview()
		}

		label.snp.makeConstraints { make in
			make.leading.equalTo(imageView.snp.trailing).offset(12)
			make.trailing.equalToSuperview().inset(2)
			make.height.greaterThanOrEqualToSuperview()
			make.centerY.equalToSuperview().inset(-2)
		}

		return view
	}()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.upperContainer])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = self.appearance.stackSpacing
        return stack
    }()

    private lazy var upperStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = self.appearance.horizontalStackSpacing
        return stack
    }()

    private lazy var upperContainer = UIView()

    private let withMenu: Bool

    init(
        withMenu: Bool = false,
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.withMenu = withMenu
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

    // MARK: - Private api

    @objc
    private func menuButtonClicked() {
        self.delegate?.profileBookingInfoViewDidClickMenu(self)
    }

    @objc
    private func feedbackButtonClicked() {
        self.delegate?.profileBookingInfoViewDidClickFeedback(self)
    }

    @objc
    private func cancelButtonClicked() {
        self.delegate?.profileBookingInfoViewDidClickCancel(self)
    }
}

extension ProfileBookingInfoActionView: ProgrammaticallyDesignable {
    func addSubviews() {
        if self.withMenu {
            self.upperStackView.addArrangedSubview(self.menuButton)
        }
        self.upperStackView.addArrangedSubview(self.feedbackButton)
        self.upperContainer.addSubview(self.upperStackView)

        self.addSubview(self.stackView)

		self.stackView.addArrangedSubview(self.cancelStub)
		self.stackView.addArrangedSubview(self.cancelButton)
    }

    func makeConstraints() {
		[self.menuButton, self.feedbackButton, self.cancelStub, self.cancelButton].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(self.appearance.height)
            }
        }

        self.upperStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.stackInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.stackInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}
