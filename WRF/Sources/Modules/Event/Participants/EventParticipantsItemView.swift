import SnapKit
import UIKit

extension EventParticipantsItemView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 18)
        let titleTextColor = UIColor.white
        let titleEditorLineHeight: CGFloat = 21
        let titleInsets = LayoutInsets(left: 10, bottom: 1, right: 10)

        let subtitleFont = UIFont.wrfFont(ofSize: 12, weight: .medium)
        let subtitleTextColor = UIColor.white.withAlphaComponent(0.8)
        let subtitleEditorLineHeight: CGFloat = 14
        let subtitleInsets = LayoutInsets(left: 10, bottom: 5, right: 10)

        let overlayColor = UIColor.black.withAlphaComponent(0.4)
    }
}

final class EventParticipantsItemView: UIView {
    let appearance: Appearance

    var title: String? {
        didSet {
            self.headerView.title = self.title
        }
    }

    var address: String? {
        didSet {
            self.headerView.address = self.address
        }
    }

    var imageURL: URL? {
        didSet {
            self.headerView.imageURL = self.imageURL
        }
    }

    var logoURL: URL? {
        didSet {
            headerView.logoURL = logoURL
        }
    }

    var distance: String? {
        didSet {
            self.headerView.distance = self.distance
        }
    }

    var price: String? {
        didSet {
            self.headerView.price = self.price
        }
    }

    var rating: Int = 0 {
        didSet {
            self.headerView.rating = self.rating
        }
    }

    var isRatingHidden = false {
        didSet {
            self.headerView.isRatingHidden = self.isRatingHidden
        }
    }

    var ratingText: String? {
        didSet {
            self.headerView.ratingText = self.ratingText
        }
    }

    private lazy var headerView = RestaurantHeaderView()

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

extension EventParticipantsItemView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.headerView)
    }

    func makeConstraints() {
        self.headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
