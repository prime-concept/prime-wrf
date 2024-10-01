import Nuke
import SnapKit
import UIKit

protocol PhotosViewDelegate: AnyObject {
    func photosViewDidClose(_ view: PhotosView)
    func photosViewDidScroll(to index: Int)
}

extension PhotosView {
    struct Appearance {
        let imageHeight: CGFloat = 250

        let closeButtonSize = CGSize(width: 32, height: 32)
        var closeButtonOffset: CGFloat = 21
        let closeButtonInsets = LayoutInsets(right: 16)
        let closeButtonColor = UIColor.white

        let previewSize = CGSize(width: 73, height: 73)
        let previewSpacing: CGFloat = 9
        let previewContentInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        let previewInsets = LayoutInsets(left: 0, bottom: 11, right: 0)

        let scrollDuration: TimeInterval = 0.2
    }
}

final class PhotosView: UIView {
    let appearance: Appearance
    weak var delegate: PhotosViewDelegate?

    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.closeButtonSize.width / 2
        return view
    }()

    // TODO: Duplicate, see `Panorama`
    private lazy var previewCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.appearance.previewSize
        layout.minimumLineSpacing = self.appearance.previewSpacing
        layout.minimumInteritemSpacing = self.appearance.previewSpacing
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellClass: PanoramaCollectionViewCell.self)
        collectionView.contentInset = self.appearance.previewContentInsets
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "panorama-icon-close"), for: .normal)
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        button.tintColor = self.appearance.closeButtonColor
        return button
    }()

    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.bounces = false
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.delegate = self
        return scroll
    }()

    private lazy var imageContainerView = UIView()

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

    func set(images: [URL]) {
        self.scrollView.layoutIfNeeded()

        let scrollWidth = self.scrollView.frame.width
        let scrollHeight = self.scrollView.frame.height

        self.scrollView.contentSize =
            CGSize(width: scrollWidth * CGFloat(images.count), height: scrollHeight)

        images.map(self.makeImageView).enumerated()
            .forEach { (index: Int, image: UIImageView) in
                image.frame.origin.x = CGFloat(index) * scrollWidth
                image.frame.size = self.scrollView.frame.size
                self.scrollView.addSubview(image)
            }
    }

    func update(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.previewCollectionView.delegate = delegate
        self.previewCollectionView.dataSource = dataSource
        self.previewCollectionView.reloadData()
    }

    func scroll(to index: Int) {
        UIView.animate(withDuration: self.appearance.scrollDuration) {
            self.scrollView.contentOffset.x = CGFloat(index) * self.scrollView.frame.width
            self.scrollView.layoutIfNeeded()
        }
    }

    func reloadPreviews() {
        self.previewCollectionView.reloadItems(at: self.previewCollectionView.indexPathsForVisibleItems)
    }

    // MARK: - Private API

    @objc
    private func closeButtonClicked() {
        self.delegate?.photosViewDidClose(self)
    }

    private func makeImageView(from url: URL) -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.loadImage(from: url)
        return imageView
    }
}

extension PhotosView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .black
    }

    func addSubviews() {
        self.imageContainerView.addSubview(self.scrollView)
        self.addSubview(self.imageContainerView)

        self.addSubview(self.visualEffectView)
        self.visualEffectView.contentView.addSubview(self.closeButton)

        self.addSubview(self.previewCollectionView)
    }

    func makeConstraints() {
        self.imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.imageContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.imageHeight)
        }

        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.visualEffectView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.closeButtonSize)
            if #available(iOS 11.0, *) {
                make.top
                    .equalTo(self.safeAreaLayoutGuide.snp.top)
                    .offset(self.appearance.closeButtonOffset)
            } else {
                make.top.equalToSuperview().offset(self.appearance.closeButtonOffset)
            }
            make.trailing.equalToSuperview().offset(-self.appearance.closeButtonInsets.right)
        }

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.previewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.previewCollectionView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.previewSize.height)
            make.leading.equalToSuperview().offset(self.appearance.previewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.previewInsets.right)

            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(self.safeAreaLayoutGuide.snp.bottom)
                    .offset(-self.appearance.previewInsets.bottom)
            } else {
                make.bottom.equalToSuperview().offset(-self.appearance.previewInsets.bottom)
            }
        }
    }
}

extension PhotosView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.width)
        self.delegate?.photosViewDidScroll(to: index)
    }
}
