import DeviceKit
import UIKit

final class PhotosViewController: UIViewController {
    enum Appearance {
        static let defaultTopOffset: CGFloat = 21
        static let smallTopOffset: CGFloat = 14
    }

    private let restaurant: Restaurant

    lazy var photosView = self.view as? PhotosView

    private var selectedImage = 0

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(restaurant: Restaurant, selectedIndex: Int) {
        self.restaurant = restaurant
        self.selectedImage = selectedIndex
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.photosView?.update(delegate: self, dataSource: self)
        self.photosView?.set(images: self.restaurant.images.map { $0.image })
        self.photosView?.scroll(to: self.selectedImage)
    }

    override func loadView() {
        let shouldUseSmallOffset = Device.current.hasSensorHousing
        var appearance = PhotosView.Appearance()
        appearance.closeButtonOffset = shouldUseSmallOffset ? Appearance.smallTopOffset : Appearance.defaultTopOffset
        let view = PhotosView(frame: UIScreen.main.bounds, appearance: appearance)
        view.delegate = self
        self.view = view
    }
}

extension PhotosViewController: PhotosViewDelegate {
    func photosViewDidClose(_ view: PhotosView) {
        self.dismiss(animated: true, completion: nil)
    }

    func photosViewDidScroll(to index: Int) {
        guard self.selectedImage != index else {
            return
        }
        self.selectedImage = index
        self.photosView?.reloadPreviews()
    }
}

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.restaurant.images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: PanoramaCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.set(isActive: indexPath.item == self.selectedImage)
        cell.set(image: self.restaurant.images[indexPath.item].image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = indexPath.item
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)

        self.photosView?.scroll(to: indexPath.row)
    }
}
