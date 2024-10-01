import UIKit

protocol ProfileBookingViewDelegate: AnyObject {
    func bookingViewDidRequestDeliveryLoad()
    func bookingViewDidRequestRestaurantsLoad()
}

extension ProfileBookingView {
    struct Appearance {
        let sectionLabelFont = UIFont.wrfFont(ofSize: 11, weight: .medium)
        let sectionLabelTextColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let sectionLabelEditorLineHeight: CGFloat = 13
        let sectionLabelInsets = LayoutInsets(left: 15)

        let bookingSectionHeight: CGFloat = 40
        let bookingItemHeight: CGFloat = 105

        let categoryViewInsets = LayoutInsets(top: 12, left: 15, bottom: 15, right: 15)
        let categoryViewHeight: CGFloat = 36
        let viewBackgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileBookingView: UIView {
    let appearance: Appearance

    weak var delegate: ProfileBookingViewDelegate?

    var showEmptyView: Bool = true {
        didSet {
            self.bookingTableView.backgroundView?.isHidden = !self.showEmptyView
            self.emptyView.state = .noData
        }
    }

    private lazy var emptyView: EmptyDataView = {
        let view = EmptyDataView()
        view.title = "Данных нет"
        view.image = #imageLiteral(resourceName: "search")
        return view
    }()
    
    private lazy var inDevelopingView: EmptyDataView = {
        let view = EmptyDataView()
        view.title = "Раздел находится в разработке\nи будет доступен позже"
        view.image = UIImage(named: "in-development")
        view.backgroundColorThemed = appearance.viewBackgroundColor
        view.isHidden = true
        return view
    }()
    private lazy var categoriesView: ProfileBookingTypesView = {
        let view = ProfileBookingTypesView()
        view.onDeliveryTap = { [weak self] in
            self?.deliverySelected()
        }

        view.onRestaurantsTap = { [weak self] in
            self?.restaurantsSelected()
        }

        return view
    }()

    private lazy var bookingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(cellClass: ProfileBookingTableViewCell.self)
        tableView.alwaysBounceVertical = true

        // Fix empty space in grouped table view
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        return tableView
    }()

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    // MARK: - Public api

    func updateTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        self.bookingTableView.delegate = delegate
        self.bookingTableView.dataSource = dataSource
        self.bookingTableView.reloadData()
    }

    func makeSectionLabel(_ title: String) -> UIView {
        let view = UIView()
        let sectionLabel = UILabel()
        sectionLabel.font = self.appearance.sectionLabelFont
        sectionLabel.textColor = self.appearance.sectionLabelTextColor
        sectionLabel.attributedText = LineHeightStringMaker.makeString(
            title.uppercased(),
            editorLineHeight: self.appearance.sectionLabelEditorLineHeight,
            font: self.appearance.sectionLabelFont
        )
        view.addSubview(sectionLabel)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.sectionLabelInsets.left)
            make.centerY.equalToSuperview()
        }
        return view
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.bookingTableView.backgroundView = self.emptyView
    }

    // MARK: - Private

    @objc
    private func deliverySelected() {
        self.delegate?.bookingViewDidRequestDeliveryLoad()
        self.inDevelopingView.isHidden = false
    }

    @objc
    private func restaurantsSelected() {
        self.categoriesView.isRestaurantsSelected = false
        self.delegate?.bookingViewDidRequestRestaurantsLoad()
        self.inDevelopingView.isHidden = true
    }
}

extension ProfileBookingView: ProgrammaticallyDesignable {
    func setupView() {
        self.inDevelopingView.state = .noData
    }

    func addSubviews() {
        self.addSubview(self.categoriesView)
        self.addSubview(self.bookingTableView)
        self.addSubview(self.inDevelopingView)
    }

    func makeConstraints() {
        self.categoriesView.translatesAutoresizingMaskIntoConstraints = false
        self.categoriesView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.categoryViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.categoryViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.categoryViewInsets.right)
            make.height.equalTo(self.appearance.categoryViewHeight)
        }

        self.bookingTableView.translatesAutoresizingMaskIntoConstraints = false
        self.bookingTableView.snp.makeConstraints { make in
            make.top.equalTo(self.categoriesView.snp.bottom).offset(self.appearance.categoryViewInsets.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        self.inDevelopingView.snp.makeConstraints { make in
            make.edges.equalTo(self.bookingTableView)
        }
    }
}
