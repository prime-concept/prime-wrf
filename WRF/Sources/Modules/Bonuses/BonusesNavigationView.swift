import UIKit
import Nuke

final class BonusesNavigationView: UIView  {
	struct Appearance {
		let grayColor = PGCMain.shared.featureFlags.appSetup.isMaisonDellosTarget
            ? UIColor(hex: 0xA79985)
            : UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
		let backgroundColor = PGCMain.shared.featureFlags.appSetup.isMaisonDellosTarget
            ? UIColor(hex: 0x2E3139)
            : UIColor.white
		let shadowColor = UIColor.black
		let shadowOpacity: CGFloat = 0.1

		let cornerRadius: CGFloat = 10
		let cardCornerRadius: CGFloat = 4
		let shadowRadius: CGFloat = 4

		let fontTitle = UIFont.wrfFont(ofSize: 16)
        let fontExisting = UIFont.wrfFont(ofSize: 12)
        let textColor = PGCMain.shared.featureFlags.appSetup.isMaisonDellosTarget
            ? UIColor(hex: 0xE3E5E5)
            : UIColor.black
        let expiringTitleColor = UIColor(hex: 0xE3E5E5).withAlphaComponent(0.6)
        let expiringDateColor = UIColor(hex: 0xFF4F4F)
	}

	private let appearance: Appearance = ApplicationAppearance.appearance()

	private var tapHandler: (() -> Void)?

    // MARK: - subviews

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = appearance.backgroundColor
        view.layer.cornerRadius = appearance.cornerRadius - 1 / UIScreen.main.scale

        view.dropShadow(
            offset: CGSize(width: 0, height: 2),
            radius: appearance.shadowRadius,
            color: appearance.shadowColor,
            opacity: appearance.shadowOpacity
        )
        return view
    }()
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "certificate-chevron")?.withRenderingMode(.alwaysTemplate)
        )
        imageView.tintColor = appearance.textColor
        return imageView
    }()
    private lazy var starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = appearance.textColor
        return imageView

    }()
    private lazy var bonusPointsLabel: UILabel = {
        let label = UILabel()
        label.text = "0 бонусных баллов"
        label.textColor = appearance.textColor
        label.font = appearance.fontTitle
        return label
    }()
    private lazy var pointsExpireLabel: UILabel = {
        let label = UILabel()
        label.text = "0 баллов сгорят"
        label.textColor = appearance.expiringTitleColor
        label.font = appearance.fontExisting
        return label
    }()
    private lazy var expirationDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = appearance.expiringDateColor
        label.font = appearance.fontExisting
        return label
    }()
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4.0
        return stackView
    }()
    private lazy var horizontalStackViewTop: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5.0
        return stackView
    }()
    private lazy var horizontalStackViewBottom: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    // MARK: - life cycle

    init() {
        super.init(frame: .zero)
        setupView()
        addSubviews()
        layoutViews()
        setupTapHandler()
    }

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - setups

    private func setupTapHandler() {
        addTapHandler { [weak self] in
            self?.tapHandler?()
        }
    }

    private func setupView() {
        backgroundColor = appearance.grayColor
        layer.cornerRadius = appearance.cornerRadius
    }

    // MARK: - layout

    private func addSubviews() {
        addSubview(contentView)
        addSubview(arrowImageView)
        verticalStackView.addArrangedSubviews([horizontalStackViewTop, horizontalStackViewBottom])
        horizontalStackViewTop.addArrangedSubviews([starImageView, bonusPointsLabel])
        horizontalStackViewBottom.addArrangedSubviews([pointsExpireLabel, expirationDateLabel])
        contentView.addSubview(verticalStackView)
    }

    private func layoutViews() {
        contentView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-45)
        }
        contentView.make(.edges(except: .trailing), .equalToSuperview)
        contentView.make(.trailing, .equalToSuperview, -45)

        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
        starImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 17, height: 17))
        }
        verticalStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(13)
            make.trailing.equalToSuperview().offset(-13)
            make.centerY.equalToSuperview()
        }
	}

	func update(with viewModel: BonusesNavigationViewModel) {
        bonusPointsLabel.text = viewModel.balance
        pointsExpireLabel.text = viewModel.expirationAmount
        expirationDateLabel.text = viewModel.expirationDate
		tapHandler = viewModel.onTap
	}
}
