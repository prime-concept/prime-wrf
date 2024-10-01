import CTPanoramaView
import Nuke
import SnapKit
import UIKit

protocol PanoramaViewDelegate: AnyObject {
    func panoramaViewDidClose(_ view: PanoramaView)
}

extension PanoramaView {
    struct Appearance {
        let gradientHeight: CGFloat = 100

        let font = UIFont.wrfFont(ofSize: 16, weight: .light)
        let textColor = UIColor.white.withAlphaComponent(0.8)
        let insets = LayoutInsets(top: 21)
        let lineHeight: CGFloat = 18

        let imageSize = CGSize(width: 72, height: 80)

        let closeButtonSize = CGSize(width: 32, height: 32)
        var closeButtonOffset: CGFloat = 21
        let closeButtonInsets = LayoutInsets(right: 16)
        let closeButtonColor = UIColor.white

        let previewSize = CGSize(width: 73, height: 73)
        let previewSpacing: CGFloat = 9
        let previewContentInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        let previewInsets = LayoutInsets(left: 0, bottom: 11, right: 0)
    }
}

final class PanoramaView: UIView {
    let appearance: Appearance
    weak var delegate: PanoramaViewDelegate?

    private var previousAngle: CGFloat = -1

    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.closeButtonSize.width / 2
        return view
    }()

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

    private lazy var panoramaView: CTPanoramaView = {
        let view = CTPanoramaView()
        view.controlMethod = .motion
        view.panoramaType = .cylindrical
        view.movementHandler = { [weak self] (rotationAngle, fovAngle) in
            guard let strongSelf = self else {
                return
            }

            guard strongSelf.dimView.superview != nil else {
                return
            }

            // movementHandler called in background
            if strongSelf.previousAngle != -1 &&
               (abs(rotationAngle - strongSelf.previousAngle) >= 0.75) {
                DispatchQueue.main.async {
                    strongSelf.hideDim()
                }
            }

            if strongSelf.previousAngle == -1 {
                strongSelf.previousAngle = rotationAngle
            }
        }
        return view
    }()

    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }()

    private lazy var imageView = UIImageView(image: UIImage(named: "panorama-icon"))
    private lazy var imageContainerView = UIView()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.imageContainerView, self.textLabel])
        view.axis = .vertical
        view.spacing = self.appearance.insets.top
        return view
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.attributedText = LineHeightStringMaker.makeString(
            "Попробуйте пошевелить\nваш iPhone",
            editorLineHeight: self.appearance.lineHeight,
            font: self.appearance.font,
            alignment: .center
        )
        label.textColor = self.appearance.textColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.75).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]
        layer.locations = [0, 0.65, 1]
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

        DispatchQueue.main.async {
            let gradientRect = CGRect(
                x: 0,
                y: 0,
                width: self.frame.width,
                height: self.appearance.gradientHeight
            )
            self.gradientLayer.frame = gradientRect
        }
    }

    func set(image: URL) {
        Nuke.loadImage(with: image, into: self.panoramaView)
    }

    func update(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.previewCollectionView.delegate = delegate
        self.previewCollectionView.dataSource = dataSource
        self.previewCollectionView.reloadData()
    }

    private func hideDim() {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.dimView.alpha = 0.0
            },
            completion: { _ in
                self.dimView.removeFromSuperview()
            }
        )
    }

    @objc
    private func closeButtonClicked() {
        self.delegate?.panoramaViewDidClose(self)
    }
}

extension PanoramaView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.panoramaView)

        self.dimView.addSubview(self.stackView)
        self.addSubview(self.dimView)
        self.imageContainerView.addSubview(self.imageView)

        self.layer.addSublayer(self.gradientLayer)

        self.addSubview(self.visualEffectView)
        self.visualEffectView.contentView.addSubview(self.closeButton)

        self.addSubview(self.previewCollectionView)
    }

    func makeConstraints() {
        self.panoramaView.translatesAutoresizingMaskIntoConstraints = false
        self.panoramaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.dimView.translatesAutoresizingMaskIntoConstraints = false
        self.dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.imageSize)
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
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

extension CTPanoramaView: ImageDisplaying {
    public func display(image: Image?) {
        self.image = image
    }
}
