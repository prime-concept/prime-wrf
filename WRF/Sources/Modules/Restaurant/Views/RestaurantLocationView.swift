import SnapKit
import UIKit

protocol RestaurantLocationViewDelegate: AnyObject {
    func restaurantLocationViewDidRequestRoute(_ view: RestaurantLocationView)
    func restaurantLocationViewDidRequestTaxiCall(_ view: RestaurantLocationView)
}

extension RestaurantLocationView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 11, weight: .medium)
        var titleTextColor = Palette.shared.textSecondary
        let titleEditorLineHeight: CGFloat = 13
        let titleInsets = LayoutInsets(top: 20, left: 15, bottom: 10, right: 15)

        let buttonsSpacing: CGFloat = 5
        let buttonsInsets = LayoutInsets(left: 15, bottom: 0, right: 15)
        let buttonHeight: CGFloat = 40
        var buttonBackgrount = Palette.shared.backgroundColor1

        let routeIconSize = CGSize(width: 20, height: 18)
        let routeIconInsets = LayoutInsets(left: 7, right: 10)

        let taxiCornerRadius: CGFloat = 10
        let taxiBackgroundColor = UIColor.black
        let taxiIconSize = CGSize(width: 54, height: 19)
        let taxiFont = UIFont.wrfFont(ofSize: 14)
        let taxiTextColor = UIColor.white
        let taxiEditorLineHeight: CGFloat = 17
        let taxiInsets = LayoutInsets(left: 15, right: 10)

        let locationFont = UIFont.wrfFont(ofSize: 14)
        var locationTextColor = Palette.shared.textPrimary
        let locationEditorLineHeight: CGFloat = 17
        let locationInsets = LayoutInsets(left: 15, right: 10)

        let taxiIconInsets = LayoutInsets(right: 10)
        let locationIconInsets = LayoutInsets(right: 10)
    }
}

final class RestaurantLocationView: UIView {
    let appearance: Appearance
    weak var delegate: RestaurantLocationViewDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.attributedText = LineHeightStringMaker.makeString(
            "Как добраться".uppercased(),
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont
        )
        label.textColorThemed = self.appearance.titleTextColor
        return label
    }()

    private lazy var locationButton: ShadowBackgroundView = {
        let button = ShadowBackgroundView()
        button.isUserInteractionEnabled = true
        button.addTapHandler { [weak self] in
            self?.locationButtonClicked()
        }
        return button
    }()

    private lazy var taxiButton: ShadowBackgroundView = {
        let button = ShadowBackgroundView(appearance: .init(shadowColor: Palette.shared.clear))
        button.isUserInteractionEnabled = true
        button.backgroundColor = self.appearance.taxiBackgroundColor
        button.layer.cornerRadius = self.appearance.taxiCornerRadius
        button.addTapHandler { [weak self] in
            self?.taxiButtonClicked()
        }
        button.isHidden = true
        return button
    }()

    private lazy var taxiLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.taxiFont
        label.attributedText = LineHeightStringMaker.makeString(
            "Приехать и уехать",
            editorLineHeight: self.appearance.taxiEditorLineHeight,
            font: self.appearance.taxiFont
        )
        label.textColor = self.appearance.taxiTextColor
        return label
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.locationFont
        label.textColorThemed = self.appearance.locationTextColor
        return label
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.locationButton /*, self.taxiButton */])
        stackView.axis = .vertical
        stackView.spacing = self.appearance.buttonsSpacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.titleInsets.top
                + self.titleLabel.intrinsicContentSize.height
                + self.appearance.titleInsets.bottom
                + self.appearance.buttonHeight * 2
                + self.appearance.buttonsInsets.bottom
        )
    }

    var address: String? {
        didSet {
            self.locationLabel.attributedText = LineHeightStringMaker.makeString(
                self.address ?? "",
                editorLineHeight: self.appearance.locationEditorLineHeight,
                font: self.appearance.locationFont,
                lineBreakMode: .byTruncatingTail
            )
        }
    }

    var taxiPrice: String? {
        didSet {
            self.taxiButton.isHidden = self.taxiPrice == nil
        }
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    @objc
    private func locationButtonClicked() {
        self.delegate?.restaurantLocationViewDidRequestRoute(self)
    }

    @objc
    private func taxiButtonClicked() {
        self.delegate?.restaurantLocationViewDidRequestTaxiCall(self)
    }

    private func makeIcon(image: UIImage, asTemplate: Bool = true) -> UIImageView {
        let view = UIImageView(image: asTemplate ? image.withRenderingMode(.alwaysTemplate) : image)

        if asTemplate {
            view.tintColorThemed = self.appearance.locationTextColor
        }

        return view
    }
}

extension RestaurantLocationView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.taxiButton.addSubview(self.taxiLabel)
        self.locationButton.addSubview(self.locationLabel)

        self.addSubview(self.titleLabel)
        self.addSubview(self.buttonsStackView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
        }

        self.locationButton.translatesAutoresizingMaskIntoConstraints = false
        self.locationButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.buttonHeight)
        }

        let locationIcon = self.makeIcon(image: #imageLiteral(resourceName: "location-route-icon-new"))
        self.locationButton.addSubview(locationIcon)
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.routeIconSize)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.locationIconInsets.right)
        }

        self.locationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.locationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.locationInsets.left)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(locationIcon.snp.leading).offset(-self.appearance.locationInsets.right)
        }

        self.taxiButton.translatesAutoresizingMaskIntoConstraints = false
        self.taxiButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.buttonHeight)
        }

        let taxiIcon = self.makeIcon(image: #imageLiteral(resourceName: "location-yandex-taxi-icon"), asTemplate: false)
        self.taxiButton.addSubview(taxiIcon)
        taxiIcon.translatesAutoresizingMaskIntoConstraints = false
        taxiIcon.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.taxiIconSize)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(self.appearance.taxiIconInsets.right)
        }

        self.taxiLabel.translatesAutoresizingMaskIntoConstraints = false
        self.taxiLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.taxiInsets.left)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(taxiIcon.snp.leading).offset(-self.appearance.taxiInsets.right)
        }

        self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.titleInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.buttonsInsets.bottom)
        }
    }
}
