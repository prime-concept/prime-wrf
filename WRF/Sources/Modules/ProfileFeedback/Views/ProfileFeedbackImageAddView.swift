import SnapKit
import UIKit

extension ProfileFeedbackImageAddView {
    struct Appearance {
        let imageSize = CGSize(width: 16, height: 16)
        let itemSize = CGSize(width: 54, height: 54)
    }
}

final class ProfileFeedbackImageAddView: UIView {
    let appearance: Appearance

    override var intrinsicContentSize: CGSize {
        return self.appearance.itemSize
    }

    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "screenshot-add-plus")
        return image
    }()

    private lazy var dashedLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.lineDashPattern = [4]
        layer.frame = self.bounds
        layer.fillColor = nil
        layer.path = UIBezierPath(ovalIn: self.bounds).cgPath
        return layer
    }()

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
        self.layer.insertSublayer(self.dashedLayer, at: 0)
    }
}

extension ProfileFeedbackImageAddView: ProgrammaticallyDesignable {
    func setupView() {
        self.layer.cornerRadius = self.appearance.itemSize.height / 2
    }

    func addSubviews() {
        self.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.appearance.imageSize)
        }
    }
}
