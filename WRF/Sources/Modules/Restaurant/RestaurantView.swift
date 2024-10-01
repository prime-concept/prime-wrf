import SnapKit
import UIKit

protocol RestaurantViewDelegate: AnyObject {
    func restaurantViewDidRequestPanorama(_ view: RestaurantView)
    func restaurantViewDidFavorite(_ view: RestaurantView)
    func restaurantViewDidShare(_ view: RestaurantView)
}

extension RestaurantView {
    struct Appearance {
        let headerHeight: CGFloat = 200

        let separatorHeight: CGFloat = 1.0
        let separatorColor = Palette.shared.strokeSecondary

        let panoramaButtonInsets = LayoutInsets(top: 5, right: 0)
        let panoramaButtonSize = CGSize(width: 44, height: 44)
        let panoramaButtonColor = UIColor.white

        let favoriteControlInsets = LayoutInsets(top: 5, left: 0, right: 5)
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class RestaurantView: UIView {
    let appearance: Appearance
    weak var delegate: RestaurantViewDelegate?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private(set) var scrollView = UIScrollView()

    private lazy var headerView = RestaurantHeaderView()
    private lazy var favoriteControl: FavoriteControl = {
        let control = FavoriteControl()
        control.isHidden = true
        control.addTarget(self, action: #selector(self.favoriteClicked), for: .touchUpInside)
        return control
    }()

    private lazy var shareControl: UIButton = {
        let control = UIButton()
        control.setImage(UIImage(named: "share-extended-button-icon"), for: .normal)
        control.addTarget(self, action: #selector(self.shareClicked), for: .touchUpInside)
        return control
    }()

    private lazy var panoramaButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "360-icon"), for: .normal)
        button.tintColor = self.appearance.panoramaButtonColor
        button.addTarget(self, action: #selector(self.panoramaButtonClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    // MARK: - Public API

    func addRowView(_ view: UIView, addSeparatorAfter: Bool = false) {
        self.stackView.addArrangedSubview(view)

        if addSeparatorAfter {
            self.stackView.addArrangedSubview(self.makeSeparator())
        }
    }

    func configure(with viewModel: RestaurantViewModel) {
        self.headerView.title = viewModel.title
        self.headerView.distance = viewModel.distanceText
        self.headerView.address = viewModel.address
        self.headerView.imageURL = viewModel.imageURL
        self.headerView.price = viewModel.price

        if let rating = viewModel.rating, let assessmentsCountText = viewModel.assessmentsCountText {
            self.headerView.rating = rating
            self.headerView.ratingText = assessmentsCountText
        }

        self.headerView.isRatingHidden = viewModel.rating == nil
        self.panoramaButton.isHidden = viewModel.panorama == nil
        self.favoriteControl.isHidden = viewModel.isFavorite == nil
        self.favoriteControl.isSelected = viewModel.isFavorite ?? false
    }

    // MARK: - Private API

    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColorThemed = self.appearance.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }
        return view
    }

    @objc
    private func panoramaButtonClicked() {
        self.delegate?.restaurantViewDidRequestPanorama(self)
    }

    @objc
    private func favoriteClicked() {
        self.delegate?.restaurantViewDidFavorite(self)
    }

    @objc
    private func shareClicked() {
        self.delegate?.restaurantViewDidShare(self)
    }
}

extension RestaurantView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.backgroundColorThemed = self.appearance.backgroundColor
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.headerView)

		let controlsStack = UIStackView.horizontal(
			self.shareControl, self.favoriteControl
		)

		self.headerView.addSubview(controlsStack)
		let insets = [self.appearance.favoriteControlInsets.top, -self.appearance.favoriteControlInsets.right]
		controlsStack.make([.top, .trailing], .equalToSuperview, insets)

        self.headerView.addSubview(self.panoramaButton)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.scrollView)
        }

        self.headerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.headerHeight)
        }

        self.panoramaButton.translatesAutoresizingMaskIntoConstraints = false
        self.panoramaButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.panoramaButtonInsets.top)
            make.trailing.equalTo(self.favoriteControl.snp.leading).offset(self.appearance.panoramaButtonInsets.right)
            make.size.equalTo(self.appearance.panoramaButtonSize)
        }
    }
}
