import Nuke
import SnapKit
import UIKit

protocol EventCellCapable: UIView {
	var itemHeight: CGFloat { get }
	var favoriteControl: FavoriteControl { get }
    var nearestRestaurant: String? { get set }

	func update(with viewModel: EventCellViewModel)
	func clear()
}

final class EventItemView: UIView, EventCellCapable {
	struct Appearance {
		let itemHeight: CGFloat = 200

		var cornerRadius: CGFloat = 15

		let nameLabelFont = UIFont.wrfFont(ofSize: 20)
		let nameLabelTextColor = UIColor.white
		let nameLabelEditorLineHeight: CGFloat = 18

		let dateLabelFont = UIFont.wrfFont(ofSize: 13)
		let dateLabelTextColor = UIColor.white.withAlphaComponent(0.8)
		let dateLabelEditorLineHeight: CGFloat = 15

		let nearestRestaurantLabelFont = UIFont.wrfFont(ofSize: 13)
		let nearestRestaurantLabelTextColor = UIColor.white.withAlphaComponent(0.8)
		let nearestRestaurantLabelEditorLineHeight: CGFloat = 15

		let nearestRestaurantIconTintColor = UIColor.white.withAlphaComponent(0.8)

		let nameLabelTopOffset: CGFloat = 3
		let stackViewSpacing: CGFloat = 8

		let favoriteImageViewInsets = LayoutInsets(top: 5, left: 0, right: 5)
		let commonInsets = LayoutInsets(left: 15, bottom: 15, right: 15)
	}

    let appearance: Appearance

    var title: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.nameLabelEditorLineHeight,
                font: self.appearance.nameLabelFont
            )
        }
    }

    var imageURL: URL? {
        didSet {
            guard let imageURL = self.imageURL else {
                return
            }
            self.imageView.loadImage(from: imageURL)
        }
    }

    var date: String? {
        didSet {
            guard let date = self.date else {
                self.dateLabel.attributedText = nil
                self.dateLabel.isHidden = true
                return
            }
            self.dateLabel.attributedText = LineHeightStringMaker.makeString(
                date,
                editorLineHeight: self.appearance.dateLabelEditorLineHeight,
                font: self.appearance.dateLabelFont
            )
        }
    }

    var nearestRestaurant: String? {
        didSet {
            guard let restaurant = self.nearestRestaurant else {
                self.nearestRestaurantStackView.isHidden = true
                return
            }
            self.nearestRestaurantStackView.isHidden = false

            self.nearestRestaurantLabel.attributedText = LineHeightStringMaker.makeString(
                restaurant,
                editorLineHeight: self.appearance.nearestRestaurantLabelEditorLineHeight,
                font: self.appearance.nearestRestaurantLabelFont,
                lineBreakMode: .byTruncatingTail
            )
        }
    }

    var isFavorite: Bool = false {
        didSet {
            self.favoriteControl.isSelected = self.isFavorite
        }
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        ]
        gradient.locations = [0, 0.48, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradient.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
        )
        return gradient
    }()

	let favoriteControl = FavoriteControl()

    private(set) var shareControl: UIButton = {
        let control = UIButton()
        control.setImage(UIImage(named: "share-extended-button-icon"), for: .normal)
        control.isHidden = true
        return control
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        return label
    }()

    private lazy var nearestRestaurantIconImageView: UIImageView = {
        let image = #imageLiteral(resourceName: "restaurant-item-distance").withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.nearestRestaurantIconTintColor
        return imageView
    }()

    private lazy var nearestRestaurantLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nearestRestaurantLabelFont
        label.textColor = self.appearance.nearestRestaurantLabelTextColor
        return label
    }()

    private(set) lazy var nearestRestaurantStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.nearestRestaurantIconImageView, self.nearestRestaurantLabel])
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.stackViewSpacing
        stackView.alignment = .center
        return stackView
    }()

    private lazy var dateAndNearestRestaurantContainerView = UIView()

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.resetOverlayPosition()
    }

    // MARK: - Public API

	func update(with viewModel: EventCellViewModel) {
		self.imageURL = viewModel.imageURL
		self.title = viewModel.title
		self.date = viewModel.date
		self.isFavorite = viewModel.isFavorite
		self.nearestRestaurant = viewModel.nearestRestaurant
		self.shareControl.isHidden = !viewModel.sharingEnabled
	}

    func clear() {
        self.imageView.image = nil
        self.titleLabel.attributedText = nil
        self.isFavorite = false
    }

	var itemHeight: CGFloat {
		self.appearance.itemHeight
	}

    // MARK: - Private api

    private func resetOverlayPosition() {
        self.gradientLayer.frame = self.imageView.bounds.insetBy(
            dx: -0.5 * self.imageView.bounds.size.width,
            dy: -self.imageView.bounds.size.height
        )
        self.gradientLayer.position = self.imageView.center
    }
}

extension EventItemView: ProgrammaticallyDesignable {
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.imageView.layer.addSublayer(self.gradientLayer)
        self.addSubview(self.favoriteControl)
        self.addSubview(self.shareControl)
        self.addSubview(self.titleLabel)
        self.addSubview(self.dateAndNearestRestaurantContainerView)
        self.dateAndNearestRestaurantContainerView.addSubview(self.dateLabel)
        self.dateAndNearestRestaurantContainerView.addSubview(self.nearestRestaurantStackView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.favoriteControl.translatesAutoresizingMaskIntoConstraints = false
        self.favoriteControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.favoriteImageViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.favoriteImageViewInsets.right)
        }

        self.shareControl.translatesAutoresizingMaskIntoConstraints = false
        self.shareControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.favoriteImageViewInsets.top)
            make.trailing.equalTo(self.favoriteControl.snp.leading).offset(
                -self.appearance.favoriteImageViewInsets.left
            )
        }

        self.dateAndNearestRestaurantContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.dateAndNearestRestaurantContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.commonInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.commonInsets.bottom)
            make.trailing.equalTo(self.nearestRestaurantStackView.snp.leading).offset(-self.appearance.commonInsets.right)
        }

        self.nearestRestaurantStackView.translatesAutoresizingMaskIntoConstraints = false
        self.nearestRestaurantStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.commonInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.commonInsets.bottom)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.bottom
                .equalTo(self.dateAndNearestRestaurantContainerView.snp.top)
                .offset(-self.appearance.nameLabelTopOffset)
            make.leading.equalToSuperview().offset(self.appearance.commonInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.commonInsets.right)
        }
    }
}
