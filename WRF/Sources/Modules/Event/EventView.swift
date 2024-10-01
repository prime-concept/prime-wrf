import SnapKit
import UIKit

protocol EventViewDelegate: AnyObject {
    func eventViewDidRequestFavoriteStatusUpdate(_ view: EventView)
    func eventViewDidRequestShare(_ view: EventView)
}

extension EventView {
    struct Appearance {
        let headerHeight: CGFloat = 200

        let participantViewInsets = LayoutInsets(top: 10, left: 15, bottom: 0, right: 15)
        let descriptionViewInsets = LayoutInsets(top: 15, left: 15, bottom: 15, right: 15)

        let bottomSpacing: CGFloat = 30.0

        var backgroundColor = PGCMain.shared.featureFlags.map.showMapSearch
                            ? Palette.shared.backgroundColor0 : Palette.shared.white
    }
}

final class EventView: UIView {
    let appearance: Appearance

    weak var delegate: EventViewDelegate?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private(set) var scrollView = UIScrollView()

    private lazy var headerView: EventHeaderView = {
        let view = EventHeaderView()
        view.eventView.favoriteControl.addTarget(self, action: #selector(self.favoriteClicked), for: .touchUpInside)
        view.eventView.shareControl.addTarget(self, action: #selector(self.shareClicked), for: .touchUpInside)
        view.eventView.shareControl.isHidden = false
        return view
    }()

    private(set) lazy var participantsView: EventParticipantsView = {
        let appearance = EventParticipantsView.Appearance(
            insets: self.appearance.participantViewInsets
        )
        let view = EventParticipantsView(appearance: appearance)
        return view
    }()

    private lazy var descriptionView: RestaurantDescriptionView = {
        let appearance = RestaurantDescriptionView.Appearance(
            insets: self.appearance.descriptionViewInsets
        )
        let view = RestaurantDescriptionView(appearance: appearance)
        view.setCustomNumberOfVisibleLines(number: PGCMain.shared.featureFlags.events.numberOfVisibleLinesInDescription)
        view.isExpandButtonAvailable = true
        return view
    }()

    // MARK: - life cycle

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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

    func update(with event: EventViewModel) {
        self.headerView.title = event.title
        self.headerView.imageURL = event.imageURL
        self.headerView.isFavorite = event.isFavorite
        self.headerView.date = event.date
        self.descriptionView.text = event.description

        if let link = event.bookingLink, !link.isEmpty {
            if let title = event.buttonTitle, !title.isEmpty {
               self.descriptionView.buttonData = (title, link)
            } else {
                self.descriptionView.buttonData = ("Подробнее", link)
            }
        }
    }

    // MARK: - Private API

    @objc
    private func favoriteClicked() {
        self.delegate?.eventViewDidRequestFavoriteStatusUpdate(self)
    }

    @objc
    private func shareClicked() {
        self.delegate?.eventViewDidRequestShare(self)
    }
}

extension EventView: ProgrammaticallyDesignable {
    func setupView() {
        backgroundColorThemed = PGCMain.shared.featureFlags.map.showMapSearch
            ? appearance.backgroundColor
            : Palette.shared.white
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.headerView)
        self.stackView.addArrangedSubview(self.descriptionView)
        self.stackView.addArrangedSubview(self.participantsView)
        self.stackView.addArrangedSubview(RestaurantSpacingView(height: self.appearance.bottomSpacing))
    }

    func makeConstraints() {
        self.scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.scrollView)
        }

        self.headerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.headerHeight)
        }
    }
}
