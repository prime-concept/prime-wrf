import UIKit

protocol RestaurantBookingActionContainerViewDelegate: AnyObject {
    func restaurantBookingActionContainerViewDidRequestCall(_ view: RestaurantBookingActionContainerView)
    func restaurantBookingActionContainerViewDidOpenMenu(_ view: RestaurantBookingActionContainerView)
}

extension RestaurantBookingActionContainerView {
    struct Appearance {
        let actionViewHeight: CGFloat = 41
        let actionViewInsets = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    }
}

final class RestaurantBookingActionContainerView: UIView {
    private lazy var actionView: RestaurantBookingActionView = {
        let view = RestaurantBookingActionView()
        view.isMenuButtonEnabled = true
        view.onBookingButtonClicked = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.restaurantBookingActionContainerViewDidRequestCall(strongSelf)
        }
        view.onMenuButtonClicked = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.restaurantBookingActionContainerViewDidOpenMenu(strongSelf)
        }
        return view
    }()

    private let appearance: Appearance

    weak var delegate: RestaurantBookingActionContainerViewDelegate?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RestaurantBookingActionContainerView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.actionView)
    }

    func makeConstraints() {
        self.actionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.actionViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.actionViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.actionViewInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.actionViewInsets.bottom)
            make.height.equalTo(self.appearance.actionViewHeight)
        }
    }
}
