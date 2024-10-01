import SnapKit
import UIKit

extension EventsView {
    struct Appearance {
        let categoryItemHeight: CGFloat = 36
        let categorySpacing: CGFloat = 10
        let categoryCollectionViewTopOffset: CGFloat = 5
        let categoryCollectionViewInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        let eventItemHeight: CGFloat = 210
        let videoEventItemHeight: CGFloat = 310
        let eventCollectionViewTopOffset: CGFloat = 11
    }
}

final class EventsView: UIView {
    let appearance: Appearance

    var showEmptyView: Bool = true {
        didSet {
            self.eventsCollectionView.backgroundView?.isHidden = !self.showEmptyView
            self.emptyView.state = .noData
        }
    }

    private lazy var emptyView: EmptyDataView = {
        let view = EmptyDataView()
        view.title = "Данных нет"
        view.image = #imageLiteral(resourceName: "search")
        return view
    }()

    private lazy var tagCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = self.appearance.categorySpacing
        layout.minimumLineSpacing = 0
        return layout
    }()

    private(set) lazy var tagsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.tagCollectionFlowLayout
        )
        collectionView.contentInset = self.appearance.categoryCollectionViewInsets
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellClass: EventTagCollectionViewCell.self)
        return collectionView
    }()

    private lazy var eventsCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()

    private(set) lazy var eventsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.eventsCollectionFlowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(cellClass: EventCollectionViewCell.self)
        collectionView.register(cellClass: EventMultipleCollectionViewCell.self)
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.eventsCollectionView.backgroundView = self.emptyView
    }

    // MARK: - Public api

    func updateCategoriesCollectionView(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource
    ) {
        self.tagsCollectionView.delegate = delegate
        self.tagsCollectionView.dataSource = dataSource
        self.tagsCollectionView.reloadData()
    }

    func updateEventsCollectionView(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource
    ) {
        self.eventsCollectionView.delegate = delegate
        self.eventsCollectionView.dataSource = dataSource
        self.eventsCollectionView.reloadData()
    }
}

extension EventsView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.tagsCollectionView)
        self.addSubview(self.eventsCollectionView)
    }

    func makeConstraints() {
        self.tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.tagsCollectionView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top
                    .equalTo(self.safeAreaLayoutGuide.snp.top)
                    .offset(self.appearance.categoryCollectionViewTopOffset)
            } else {
                make.top
                    .equalToSuperview()
                    .offset(self.appearance.categoryCollectionViewTopOffset)
            }
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.categoryItemHeight)
        }

        self.eventsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.eventsCollectionView.snp.makeConstraints { make in
            make.top
                .equalTo(self.tagsCollectionView.snp.bottom)
                .offset(self.appearance.eventCollectionViewTopOffset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
