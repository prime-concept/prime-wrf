import SnapKit
import UIKit

protocol StarsRatingViewDelegate: AnyObject {
    func ratingViewDidSelectRating(_ view: StarsRatingView)
}

extension StarsRatingView {
    struct Appearance {
        var starFilledColor = Palette.shared.iconsBrand
        var starClearColor = Palette.shared.iconsSecondary

        var starsSpacing: CGFloat = 3
        var starsSize = CGSize(width: 12, height: 11)
        var starsImage: UIImage = #imageLiteral(resourceName: "restaurant-item-star")
    }
}

final class StarsRatingView: UIView {
    let appearance: Appearance

    weak var delegate: StarsRatingViewDelegate?

    private static let maxStarsCount = 5

    private lazy var starsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.starsSpacing
        return stackView
    }()

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(self.starClicked(_:))
    )

    var starsCount: Int = 0 {
        didSet {
            self.updateStars(count: self.starsCount)
            self.delegate?.ratingViewDidSelectRating(self)
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateStars(count: Int) {
        self.starsStackView.removeAllArrangedSubviews()
        let count = min(StarsRatingView.maxStarsCount, count)

        for _ in 0..<count {
            self.starsStackView.addArrangedSubview(self.makeStar(isFilled: true))
        }

        for _ in 0..<(StarsRatingView.maxStarsCount - count) {
            self.starsStackView.addArrangedSubview(self.makeStar(isFilled: false))
        }
    }

    private func makeStar(isFilled: Bool) -> UIView {
        let imageView = UIImageView(image: self.appearance.starsImage.withRenderingMode(.alwaysTemplate))
        imageView.tintColorThemed = isFilled ? self.appearance.starFilledColor : self.appearance.starClearColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.starsSize)
        }
        return imageView
    }

    @objc
    private func starClicked(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.starsStackView)
        for (index, subview) in self.starsStackView.arrangedSubviews.enumerated()
            where subview.frame.contains(location) {
            self.starsCount = index + 1
        }
        self.delegate?.ratingViewDidSelectRating(self)
    }
}

extension StarsRatingView: ProgrammaticallyDesignable {
    func setupView() {
        self.updateStars(count: self.starsCount)
        self.addGestureRecognizer(self.tapGestureRecognizer)
        self.isUserInteractionEnabled = false
    }

    func addSubviews() {
        self.addSubview(self.starsStackView)
    }

    func makeConstraints() {
        self.starsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.starsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
