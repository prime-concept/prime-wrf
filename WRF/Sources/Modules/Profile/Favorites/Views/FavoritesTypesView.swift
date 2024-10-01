import PromiseKit
import SnapKit
import UIKit

extension FavoritesTypesView {
    struct Appearance {
        let tagsSpacing: CGFloat = 5
    }
}

final class FavoritesTypesView: UIView {
    let appearance: Appearance

    private(set) lazy var restaurantsTagView: SimpleTagItemView = {
        let view = SimpleTagItemView()
        view.title = "Рестораны"
        view.image = #imageLiteral(resourceName: "restaurant-tag")
        return view
    }()

    private(set) lazy var eventsTagView: SimpleTagItemView = {
        let view = SimpleTagItemView()
        view.title = "События"
        view.image = #imageLiteral(resourceName: "event-mock-background")
        return view
    }()

    private lazy var tagsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.restaurantsTagView, self.eventsTagView])
        stack.axis = .horizontal
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
}

extension FavoritesTypesView: ProgrammaticallyDesignable {
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
