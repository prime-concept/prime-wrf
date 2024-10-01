import SnapKit
import UIKit

extension RestaurantPhotoItemView {
    struct Appearance {
    }
}

final class RestaurantPhotoItemView: UIView {
    let appearance: Appearance

    var imageURL: URL? {
        didSet {
            guard let url = self.imageURL else {
                self.backgroundImageView.image = nil
                return
            }
            self.backgroundImageView.loadImage(from: url)
        }
    }

    private lazy var backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        return view
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

    func clear() {
        self.backgroundImageView.image = nil
    }
}

extension RestaurantPhotoItemView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.backgroundImageView)
    }

    func makeConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
