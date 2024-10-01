import SnapKit
import UIKit

final class ProfileAboutHeaderView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = PGCResources.Images.About.header
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var overlayGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
        )
        return layer
    }()

    override init(frame: CGRect) {
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
        self.resetOverlayPosition()
    }

    // MARK: - Private API

    private func resetOverlayPosition() {
        self.overlayGradientLayer.bounds = self.imageView.bounds.insetBy(
            dx: -0.5 * self.imageView.bounds.size.width,
            dy: -self.imageView.bounds.size.height
        )
        self.overlayGradientLayer.position = self.imageView.center
    }
}

extension ProfileAboutHeaderView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.imageView.layer.addSublayer(self.overlayGradientLayer)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
