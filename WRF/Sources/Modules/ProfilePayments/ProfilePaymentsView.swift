import SnapKit
import UIKit

protocol ProfilePaymentsViewDelegate: AnyObject {
    func viewDidRequestPaymentAdd()
}

extension ProfilePaymentsView {
    struct Appearance {
        let itemSpacing: CGFloat = 10
        let itemSize = CGSize(width: 160, height: 100)
        let collectionViewInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        let descriptionFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        let descriptionColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let descriptionEditorLineHeight: CGFloat = 18
        let descriptionOffset = LayoutInsets(top: 25, left: 15, right: 15)

        let emptyViewImageSize = CGSize(width: 44, height: 44)

        let paymentsCollectionViewTopOffset: CGFloat = 25
        let paymentsCollectionViewHeight: CGFloat = 100
    }
}

final class ProfilePaymentsView: UIView {
    let appearance: Appearance

    var showEmptyView: Bool = false {
        didSet {
            self.emptyView.isHidden = !self.showEmptyView
        }
    }

    weak var delegate: ProfilePaymentsViewDelegate?

    private lazy var emptyView: EmptyDataView = {
        var appearance: EmptyDataView.Appearance = ApplicationAppearance.appearance()
        appearance.iconSize = self.appearance.emptyViewImageSize
        appearance.spacing = 0
        let view = EmptyDataView(appearance: appearance)
        view.title = "Добавить карту"
        view.image = #imageLiteral(resourceName: "payment-add")
        view.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.emptyViewClicked))
        view.addGestureRecognizer(gesture)
        return view
    }()

    private lazy var paymentsCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = self.appearance.itemSpacing
        layout.minimumLineSpacing = 0
        return layout
    }()

    private(set) lazy var paymentsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.paymentsCollectionFlowLayout
        )
        collectionView.contentInset = self.appearance.collectionViewInsets
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellClass: ProfilePaymentsCollectionViewCell.self)
        return collectionView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.descriptionFont
        label.textColor = self.appearance.descriptionColor
        label.attributedText = LineHeightStringMaker.makeString(
            "Карта зашифрована в KeyChain и доступна только на этом устройстве",
            editorLineHeight: self.appearance.descriptionEditorLineHeight,
            font: self.appearance.descriptionFont
        )
        return label
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
        self.emptyView.frame = self.paymentsCollectionView.frame
    }

    // MARK: - Public API

    func updateCollectionView(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource
    ) {
        self.paymentsCollectionView.delegate = delegate
        self.paymentsCollectionView.dataSource = dataSource
        self.paymentsCollectionView.reloadData()
    }

    // MARK: - Private API

    @objc
    private func emptyViewClicked() {
        self.delegate?.viewDidRequestPaymentAdd()
    }
}

extension ProfilePaymentsView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
        self.showEmptyView = false
    }

    func addSubviews() {
        self.addSubview(self.paymentsCollectionView)
        self.addSubview(self.emptyView)
        self.addSubview(self.descriptionLabel)
    }

    func makeConstraints() {
        self.paymentsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.paymentsCollectionView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top
                    .equalTo(self.safeAreaLayoutGuide.snp.top)
                    .offset(self.appearance.paymentsCollectionViewTopOffset)
            } else {
                make.top
                    .equalToSuperview()
                    .offset(self.appearance.paymentsCollectionViewTopOffset)
            }
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.paymentsCollectionViewHeight)
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.paymentsCollectionView.snp.bottom).offset(self.appearance.descriptionOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.descriptionOffset.left)
            make.trailing.equalToSuperview().offset(self.appearance.descriptionOffset.right)
        }
    }
}
