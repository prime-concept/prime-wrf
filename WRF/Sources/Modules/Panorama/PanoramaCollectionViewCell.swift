import Nuke
import SnapKit
import UIKit

extension PanoramaCollectionViewCell {
    enum Appearance {
        static let borderWidth: CGFloat = 2
        static let borderColor = UIColor.white.withAlphaComponent(0.7)
        static let cornerRadius: CGFloat = 10
        static let imageCornerRadius: CGFloat = 8

        static let insets = LayoutInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
}

final class PanoramaCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Appearance.imageCornerRadius
        return view
    }()

    private lazy var previewView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = Appearance.borderWidth
        view.layer.borderColor = Appearance.borderColor.cgColor
        view.layer.cornerRadius = Appearance.cornerRadius
        view.clipsToBounds = true
        return view
    }()

    func set(isActive: Bool) {
        self.previewView.layer.borderColor = isActive
            ? Appearance.borderColor.cgColor
            : UIColor.clear.cgColor
    }

    func set(image: URL) {
        self.imageView.loadImage(from: image)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.previewView.superview == nil {
            self.contentView.addSubview(self.previewView)
            self.previewView.addSubview(self.imageView)

            self.previewView.translatesAutoresizingMaskIntoConstraints = false
            self.previewView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            self.imageView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(Appearance.insets.top)
                make.leading.equalToSuperview().offset(Appearance.insets.left)
                make.trailing.equalToSuperview().offset(-Appearance.insets.right)
                make.bottom.equalToSuperview().offset(-Appearance.insets.bottom)
            }
        }
    }
}
