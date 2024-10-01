import SnapKit
import UIKit

protocol MapViewDelegate: AnyObject {
    func mapViewDidSelectSearch(_ view: MapView)
    func mapViewDidSelectCurrentLocation(_ view: MapView)
    func mapViewDidSelectFilter(_ view: MapView)
    func mapViewDidSelectNotifications(_ view: MapView)
    func mapViewDidTapCity(_ view: MapView)
    func mapViewDidTapClose(_ view: MapView)
}

extension MapView {
    struct Appearance {
        var restaurantsContainerHeight: CGFloat = 150
        let collapsedOverlayViewHeightMultiplier: CGFloat = 1/3
        let expandedOverlayViewHeightMultiplier: CGFloat = 0.9
        private(set) lazy var overlayViewMidpointMultiplier: CGFloat = {
            abs(expandedOverlayViewHeightMultiplier - collapsedOverlayViewHeightMultiplier)
        }()
        let restaurantsCellHeight: CGFloat = 104

        var topOffset: CGFloat = 8
        let tagsViewHeight: CGFloat = 50
        let tagsCollectionViewInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let tagsSpacing: CGFloat = 5

        let buttonSize = CGSize(width: 42, height: 36)
        let searchButtonInsets = LayoutInsets(left: 5, right: 15)
        let chatButtonInsets = LayoutInsets(top: 14, right: 15)
        let notificationButtonInsets = LayoutInsets(top: 14, right: 15)
        let locationButtonInsets = LayoutInsets(bottom: 10, right: 15)
        let filterButtonInsets = LayoutInsets(left: 15, right: 5)

        let cityButtonOffset = LayoutInsets(left: 15.0)

        let closeButtonBorder: CGFloat = 1.0
        let closeButtonBackgroundColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 0.5)
        let cityButtonBorderColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 0.5)
        let closeButtonBorderColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 0.5)
        let closeButtonInsets = LayoutInsets(left: 15.0, right: 15.0)
        let closeButtonSize = CGSize(width: 38.0, height: 32.0)
        let closeButtonRadius: CGFloat = 6.0

        let padViewBackgroundColor = UIColor.white.withAlphaComponent(0.4)
        let bottomSheetViewBackgroundColor = UIColor(red: 0.16, green: 0.16, blue: 0.2, alpha: 1.0)

        let visaLogoSize = CGSize(width: 47.0, height: 15.0)
        let visaLogoRightInset: CGFloat = 15.0
        let bottomSheetTopSpace: CGFloat = 34.0
        let headerIndicatorHeight: CGFloat = 4.0
        let hiderIndicatorWidth: CGFloat = 40.0
    }
}

final class MapView: UIView {
    private(set) var appearance: Appearance

    weak var delegate: MapViewDelegate?

    private var initialOverlayViewHeight: CGFloat?

    var filterCount: Int = 0 {
        didSet {
            guard self.filterCount != 0 else {
                self.filterButton.badgeCount = nil
                return
            }
            self.filterButton.badgeCount = self.filterCount
        }
    }

    var notificationCount: Int = 0 {
        didSet {
            guard self.notificationCount != 0 else {
                self.notificationButton.badgeCount = nil
                return
            }
            self.notificationButton.badgeCount = self.notificationCount
        }
    }

    var isNotificationEnabled: Bool = false {
        didSet {
            self.notificationButton.isHidden = !self.isNotificationEnabled
        }
    }

    private lazy var tagsCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = self.appearance.tagsSpacing
        layout.minimumLineSpacing = self.appearance.tagsSpacing
        return layout
    }()

    private lazy var restaurantsTablePadView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = PGCMain.shared.featureFlags.map.showMapSearch
            ? UIColor.clear
            : appearance.padViewBackgroundColor
        return view
    }()

    private lazy var restaurantsBottomSheetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = self.appearance.bottomSheetViewBackgroundColor
        view.addGestureRecognizer(
            UIPanGestureRecognizer(
                target: self,
                action: #selector(handlePanGesture)
            )
        )
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20.0
        view.clipsToBounds = true
        return view
    }()

    private lazy var visaLogoImageView: UIView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "visa-logo")
        view.isHidden = !PGCMain.shared.featureFlags.map.showVISALogo
        return view
    }()

    private var restaurantsLoadingIndicator = WineLoaderView()

    private(set) lazy var tagsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.tagsCollectionFlowLayout
        )
        collectionView.contentInset = self.appearance.tagsCollectionViewInsets
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellClass: MapTagsCollectionViewCell.self)

        return collectionView
    }()

    private(set) lazy var restaurantsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(cellClass: MapRestaurantsTableViewCell.self)
        tableView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.0)
        tableView.estimatedRowHeight = self.appearance.restaurantsCellHeight
        return tableView
    }()

    private lazy var searchButton: MapButton = {
        let button = MapButton()
        button.image = #imageLiteral(resourceName: "map-button-search")
        button.addTarget(target: self, action: #selector(self.searchClicked), for: .touchUpInside)
        return button
    }()

    private lazy var chatButton: MapButton = {
        let button = MapButton()
        button.badgeCount = 45
        button.image = #imageLiteral(resourceName: "map-button-chat")
        button.isHidden = true
        return button
    }()

    private lazy var notificationButton: MapButton = {
        let button = MapButton()
        button.image = #imageLiteral(resourceName: "map-button-notification")
        button.isHidden = true
        button.addTarget(target: self, action: #selector(self.notificationClicked), for: .touchUpInside)
        return button
    }()

    private(set) lazy var locationButton: MapButton = {
        let button = MapButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.image = #imageLiteral(resourceName: "map-button-location")
        button.addTarget(target: self, action: #selector(self.locationClicked), for: .touchUpInside)
        return button
    }()

    private lazy var filterButton: MapButton = {
        let button = MapButton()
        button.image = UIImage(named: "map-button-filter")
        button.addTarget(target: self, action: #selector(self.filterClicked), for: .touchUpInside)
        return button
    }()

    private lazy var cityButton: MapDropdownButtonView = {
        let appearance = MapDropdownButtonView.Appearance(
            backgroundColor: Palette.shared.backgroundColorInverse2,
            borderColor: Palette.shared.strokePrimary
        )
        let button = MapDropdownButtonView(appearance: appearance)
        button.addTapHandler { [weak self] in
            self?.cityButtonTapped()
        }
        button.update(with: .init(title: "Город"))
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderWidth = appearance.closeButtonBorder
        button.layer.borderColor = appearance.cityButtonBorderColor.cgColor
        button.layer.cornerRadius = appearance.closeButtonRadius
        button.setImage(UIImage(named: "map-close-cross-icon"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var headerViewDraggingIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        view.clipsToBounds = true
        view.layer.cornerRadius = 2
        return view
    }()
    
    private var mapView: UIView?
    private var isFullSize = false
    private var restaurantPadHeightConstraint: Constraint?
    private var restaurantsBottomSheetHeightConstraint: Constraint?

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
        self.tagsCollectionView.collectionViewLayout.invalidateLayout()
    }

    func resetTableView() {
        self.restaurantsTableView.setContentOffset(
            CGPoint(x: 0, y: -self.restaurantsTableView.contentInset.top),
            animated: false
        )
    }

    func updateTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        self.restaurantsTableView.delegate = delegate
        self.restaurantsTableView.dataSource = dataSource
        self.restaurantsTableView.reloadData()

        self.scrollToRestaurant(index: 0)
        self.updateRestaurantPadHeight()
    }

    func updateTagsCollectionView(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.tagsCollectionView.delegate = delegate
        self.tagsCollectionView.dataSource = dataSource
        self.tagsCollectionView.collectionViewLayout.invalidateLayout()
        self.tagsCollectionView.reloadData()
    }

    func updateMapView(view: UIView) {
        self.mapView?.removeFromSuperview()

        self.insertSubview(view, at: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.mapView = view
    }

    func scrollToRestaurant(index: Int) {
        guard self.restaurantsTableView.numberOfSections > 0 else {
            return
        }

        guard self.restaurantsTableView.numberOfRows(inSection: 0) > index else {
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        let cellHeight = self.appearance.restaurantsCellHeight
        self.restaurantsTableView.setContentOffset(CGPoint(x: 0, y: index * Int(cellHeight)), animated: true)

        // selecting row
        for currentIndexPath in self.restaurantsTableView.indexPathsForVisibleRows ?? [] {
            let isSelected = currentIndexPath == indexPath
            self.restaurantsTableView.cellForRow(at: currentIndexPath)?.isSelected = isSelected
            if isSelected {
                self.restaurantsTableView.selectRow(at: currentIndexPath, animated: false, scrollPosition: .none)
            } else {
                self.restaurantsTableView.deselectRow(at: currentIndexPath, animated: false)
            }
        }
    }

    func hideLoading() {
        self.restaurantsLoadingIndicator.stopAnimating()
        self.restaurantsTablePadView.backgroundColor = .clear
    }

    func setupCityButton(title: String) {
        cityButton.update(with: .init(title: title))
    }
    
    // MARK: - Overlay View Expansion
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            initialOverlayViewHeight = restaurantsBottomSheetView.frame.height
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            performDragging(verticalTranslation: translation.y)
        case .ended:
            let velocity = recognizer.velocity(in: recognizer.view)
            performSnapping(verticalVelocity: velocity.y)
        default: 
            break
        }
    }
    
    private func performDragging(verticalTranslation: CGFloat) {
        let shouldMoveView = !(-1...1).contains(verticalTranslation)
        guard shouldMoveView, let initialOverlayViewHeight else { return }
        
        let newHeight = resultingOverlayViewHeight(
            initialHeight: initialOverlayViewHeight,
            verticalTranslation: verticalTranslation
        )
        
        restaurantsBottomSheetHeightConstraint?.update(offset: newHeight)
        layoutIfNeeded()
    }
    
    private func resultingOverlayViewHeight(initialHeight: CGFloat, verticalTranslation: CGFloat) -> CGFloat {
        let proposedHeight = initialHeight - verticalTranslation
        let resolvedHeight: CGFloat
        if overlayViewShouldPerformRubberBandEffect(
            initialState: initialOverlayViewState(viewHeight: initialHeight), 
            initialHeight: initialHeight,
            proposedHeight: proposedHeight
        ) {
            let totalTranslation = initialHeight - proposedHeight
            let adjustedTranslation = log10(abs(totalTranslation)) * 5 * (totalTranslation < 0 ? -1 : 1)
            resolvedHeight = initialHeight - adjustedTranslation
        } else {
            resolvedHeight = proposedHeight
        }
        
        return resolvedHeight
    }
    
    private func initialOverlayViewState(viewHeight: CGFloat) -> OverlayViewState {
        let heightMidpoint = frame.height * appearance.overlayViewMidpointMultiplier
        if viewHeight > heightMidpoint {
            return .expanded
        } else {
            return .collapsed
        }
    }
    
    private func overlayViewShouldPerformRubberBandEffect(
        initialState: OverlayViewState,
        initialHeight: CGFloat,
        proposedHeight: CGFloat
    ) -> Bool {
        switch initialState {
        case .collapsed: proposedHeight < initialHeight
        case .expanded: proposedHeight > initialHeight
        }
    }
    
    private func performSnapping(verticalVelocity: CGFloat) {
        let resultingState = resultingOverlayViewState(
            verticalVelocity: verticalVelocity,
            currentHeight: restaurantsBottomSheetView.frame.height
        )
        animateOverlayView(to: resultingState, currentHeight: restaurantsBottomSheetView.frame.height)
    }
    
    private func resultingOverlayViewState(verticalVelocity: CGFloat, currentHeight: CGFloat) -> OverlayViewState {
        switch verticalVelocity {
        case ...(-100):
            return .expanded
        case 100...:
            return .collapsed
        default:
            let snapThreshold = frame.height * appearance.overlayViewMidpointMultiplier
            if currentHeight > snapThreshold {
                return .expanded
            } else {
                return .collapsed
            }
        }
    }
    
    private func animateOverlayView(to state: OverlayViewState, currentHeight: CGFloat) {
        let targetHeight = targetHeight(for: state)
        
        let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1.0) {
            self.restaurantsBottomSheetHeightConstraint?.update(offset: targetHeight)
            self.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    private func targetHeight(for state: OverlayViewState) -> CGFloat {
        switch state {
        case .collapsed:
            frame.height * appearance.collapsedOverlayViewHeightMultiplier
        case .expanded:
            frame.height * appearance.expandedOverlayViewHeightMultiplier
        }
    }
    
    // MARK: - Private api

    @objc
    private func searchClicked() {
        self.delegate?.mapViewDidSelectSearch(self)
    }

    @objc
    private func locationClicked() {
        self.delegate?.mapViewDidSelectCurrentLocation(self)
    }

    @objc
    private func filterClicked() {
        self.delegate?.mapViewDidSelectFilter(self)
    }

    @objc
    private func cityButtonTapped() {
        delegate?.mapViewDidTapCity(self)
    }

    @objc
    private func closeButtonTapped() {
        delegate?.mapViewDidTapClose(self)
    }

    @objc
    private func notificationClicked() {
        self.delegate?.mapViewDidSelectNotifications(self)
    }

    private func updateRestaurantPadHeight() {
        guard self.restaurantsTableView.numberOfSections > 0 else {
            return
        }

        let rowCount = self.restaurantsTableView.numberOfRows(inSection: 0)
        guard rowCount > 0 else {
            return
        }
        let defaultContainerHeight = self.appearance.restaurantsContainerHeight
        let newContainerHeight = CGFloat(rowCount) * self.appearance.restaurantsCellHeight
        let containerHeight = min(defaultContainerHeight, newContainerHeight)
        self.restaurantPadHeightConstraint?.update(offset: containerHeight)

        self.restaurantsTableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: containerHeight - MapRestaurantsTableViewCell.Appearance.itemHeight,
            right: 0
        )
    }

}

extension MapView: ProgrammaticallyDesignable {
    func addSubviews() {
        restaurantsTablePadView.addSubview(restaurantsTableView)
        restaurantsTablePadView.addSubview(restaurantsLoadingIndicator)
        addSubview(locationButton)
        if PGCMain.shared.featureFlags.map.showMapSearch {
            addSubview(cityButton)
            addSubview(closeButton)
            addSubview(restaurantsBottomSheetView)
            restaurantsBottomSheetView.addSubview(restaurantsTablePadView)
            restaurantsBottomSheetView.addSubview(headerViewDraggingIndicator)
        } else {
            addSubview(restaurantsTablePadView)
            addSubview(filterButton)
            addSubview(tagsCollectionView)
            addSubview(searchButton)
            addSubview(chatButton)
            addSubview(notificationButton)
            addSubview(visaLogoImageView)
        }
    }

    func makeConstraints() {
        if PGCMain.shared.featureFlags.map.showMapSearch {
            cityButton.snp.makeConstraints {
                $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(appearance.topOffset)
                $0.leading.equalToSuperview().offset(appearance.cityButtonOffset.left)
            }
            closeButton.snp.makeConstraints {
                $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(appearance.topOffset)
                $0.trailing.equalToSuperview().offset(-appearance.closeButtonInsets.right)
                $0.size.equalTo(appearance.closeButtonSize)
            }
            headerViewDraggingIndicator.snp.makeConstraints {
                $0.top.equalToSuperview().offset(appearance.bottomSheetTopSpace / 2.0 - appearance.headerIndicatorHeight / 2.0)
                $0.centerX.equalToSuperview()
                $0.height.equalTo(appearance.headerIndicatorHeight)
                $0.width.equalTo(appearance.hiderIndicatorWidth)
            }
            restaurantsBottomSheetView.snp.makeConstraints {
                $0.leading.bottom.trailing.equalToSuperview()
                restaurantsBottomSheetHeightConstraint = $0.height
                    .equalTo(frame.height * appearance.collapsedOverlayViewHeightMultiplier)
                    .constraint
            }
            restaurantsTablePadView.snp.makeConstraints {
                $0.left.right.bottom.equalToSuperview()
                $0.top.equalToSuperview().inset(appearance.bottomSheetTopSpace)
            }
        } else {
            self.restaurantsTablePadView.snp.makeConstraints { make in
                make.leading.bottom.trailing.equalToSuperview()
                self.restaurantPadHeightConstraint = make.height
                    .equalTo(self.appearance.restaurantsContainerHeight).constraint
            }
            self.filterButton.translatesAutoresizingMaskIntoConstraints = false
            self.filterButton.snp.makeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(self.appearance.topOffset)
                make.leading.equalToSuperview().offset(self.appearance.filterButtonInsets.left)
                make.size.equalTo(self.appearance.buttonSize)
            }

            self.tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
            self.tagsCollectionView.snp.makeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(self.appearance.topOffset)
                make.leading.equalTo(self.filterButton.snp.trailing).offset(self.appearance.filterButtonInsets.right)
                make.height.equalTo(self.appearance.tagsViewHeight)
            }

            self.searchButton.translatesAutoresizingMaskIntoConstraints = false
            self.searchButton.snp.makeConstraints { make in
                make.size.equalTo(self.appearance.buttonSize)
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(self.appearance.topOffset)
                make.trailing.equalToSuperview().offset(-self.appearance.searchButtonInsets.right)
                make.leading.equalTo(self.tagsCollectionView.snp.trailing).offset(self.appearance.searchButtonInsets.left)
            }

            self.chatButton.translatesAutoresizingMaskIntoConstraints = false
            self.chatButton.snp.makeConstraints { make in
                make.size.equalTo(self.appearance.buttonSize)
                make.trailing.equalToSuperview().offset(-self.appearance.chatButtonInsets.right)
                make.top.equalTo(self.searchButton.snp.bottom).offset(self.appearance.chatButtonInsets.top)
            }

            self.notificationButton.translatesAutoresizingMaskIntoConstraints = false
            self.notificationButton.snp.makeConstraints { make in
                make.size.equalTo(self.appearance.buttonSize)
                make.trailing.equalToSuperview().offset(-self.appearance.notificationButtonInsets.right)
                make.top.equalTo(self.searchButton.snp.bottom).offset(self.appearance.notificationButtonInsets.top)
            }
            self.visaLogoImageView.snp.makeConstraints { make in
                make.size.equalTo(self.appearance.visaLogoSize)
                make.trailing.equalTo(self.locationButton.snp.leading).offset(-self.appearance.visaLogoRightInset)
                make.centerY.equalTo(self.locationButton.snp.centerY)
            }
        }

        self.restaurantsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.restaurantsLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.locationButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.buttonSize)
            make.trailing.equalToSuperview().offset(-self.appearance.locationButtonInsets.right)
            make.bottom
                .equalTo(
                    PGCMain.shared.featureFlags.map.showMapSearch
                        ? restaurantsBottomSheetView.snp.top
                        : restaurantsTablePadView.snp.top
                )
                .offset(-self.appearance.locationButtonInsets.right)
        }
    }
}

// MARK: - OverlayViewState

extension MapView {
    
    private enum OverlayViewState {
        case collapsed
        case expanded
    }
    
}
