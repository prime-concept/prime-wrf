import SnapKit
import UIKit

extension EventHeaderView {
    struct Appearance {
    }
}

final class EventHeaderView: UIView {
    let appearance: Appearance

    var title: String? {
        didSet {
            self.eventView.title = self.title
        }
    }

    var imageURL: URL? {
        didSet {
            self.eventView.imageURL = self.imageURL
        }
    }

    var date: String? {
        didSet {
            self.eventView.date = self.date
        }
    }

    var isFavorite: Bool = false {
        didSet {
            self.eventView.isFavorite = self.isFavorite
        }
    }

    private(set) lazy var eventView: EventItemView = {
        let appearance = EventItemView.Appearance(
            cornerRadius: 0
        )
        let view = EventItemView(appearance: appearance)
        view.nearestRestaurantStackView.isHidden = true
        return view
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

extension EventHeaderView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.eventView)
    }

    func makeConstraints() {
        self.eventView.translatesAutoresizingMaskIntoConstraints = false
        self.eventView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
