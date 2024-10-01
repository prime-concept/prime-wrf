import CTPanoramaView
import DeviceKit
import UIKit

final class PanoramaViewController: UIViewController {
    enum Appearance {
        static let defaultTopOffset: CGFloat = 21
        static let smallTopOffset: CGFloat = 14
    }

    private let seed: PanoramaSeed

    lazy var panoramaView = self.view as? PanoramaView

    private var selectedImage = 0

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(seed: PanoramaSeed) {
        self.seed = seed
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.panoramaView?.update(delegate: self, dataSource: self)

        if let image = self.seed.images.first?.image {
            self.panoramaView?.set(image: image)
        }
    }

    override func loadView() {
        let shouldUseSmallOffset = Device.current.hasSensorHousing
        var appearance = PanoramaView.Appearance()
        appearance.closeButtonOffset = shouldUseSmallOffset ? Appearance.smallTopOffset : Appearance.defaultTopOffset
        let view = PanoramaView(frame: UIScreen.main.bounds, appearance: appearance)
        view.delegate = self
        self.view = view
    }
}

extension PanoramaViewController: PanoramaViewDelegate {
    func panoramaViewDidClose(_ view: PanoramaView) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PanoramaViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.seed.images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: PanoramaCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.set(isActive: indexPath.item == self.selectedImage)
        cell.set(image: self.seed.images[indexPath.item].preview)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = indexPath.item
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)

        self.panoramaView?.set(image: self.seed.images[indexPath.item].image)
    }
}
