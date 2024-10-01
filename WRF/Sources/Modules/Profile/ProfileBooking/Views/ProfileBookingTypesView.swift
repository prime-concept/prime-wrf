import PromiseKit
import SnapKit
import UIKit

extension ProfileBookingTypesView {
    struct Appearance {
        let tagsSpacing: CGFloat = 5
    }
}

final class ProfileBookingTypesView: UIView {
    let appearance: Appearance

    var onRestaurantsTap: (() -> Void)?
    var onDeliveryTap: (() -> Void)?

    var isDeliverySelected: Bool = true {
        didSet {
            self.deliveryTagView.isSelected = self.isDeliverySelected
            self.restaurantsTagView.isSelected = !self.isDeliverySelected
        }
    }

    var isRestaurantsSelected: Bool = false {
        didSet {
            self.deliveryTagView.isSelected = !self.isDeliverySelected
            self.restaurantsTagView.isSelected = self.isDeliverySelected
        }
    }

    private lazy var deliveryTagView: SimpleTagItemView = {
        let view = SimpleTagItemView()
        view.title = "Доставка"
        view.image = #imageLiteral(resourceName: "delivery-tag")
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.deliveryTagViewClicked))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var restaurantsTagView: SimpleTagItemView = {
        let view = SimpleTagItemView()
        view.title = "Брони"
        view.image = #imageLiteral(resourceName: "restaurant-tag")
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.restaurantsTagViewClicked))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var tagsStackView: UIStackView = {
        let stack = UIStackView(.horizontal)
        stack.addArrangedSubview(restaurantsTagView)
        if PGCMain.shared.featureFlags.profile.shouldShowDeliveries {
            stack.addArrangedSubview(deliveryTagView)
        }
        stack.spacing = self.appearance.tagsSpacing
        return stack
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

    @objc
    private func restaurantsTagViewClicked() {
        self.onRestaurantsTap?()
    }

    @objc
    private func deliveryTagViewClicked() {
        self.onDeliveryTap?()
    }
}

extension ProfileBookingTypesView: ProgrammaticallyDesignable {
    func setupView() {
        self.isRestaurantsSelected = true
    }

    public func addSubviews() {
        self.addSubview(self.tagsStackView)
    }

    public func makeConstraints() {
        self.tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.tagsStackView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}
