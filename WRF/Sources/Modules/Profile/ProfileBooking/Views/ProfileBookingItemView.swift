import UIKit

extension ProfileBookingItemView {
    struct Appearance {
        let cornerRadius: CGFloat = 10

        let nameFont = UIFont.wrfFont(ofSize: 20)
        let nameInsets = LayoutInsets(left: 14)
        let nameTextColor = UIColor.white
        let nameEditorLineHeight: CGFloat = 23

        let addressFont = UIFont.wrfFont(ofSize: 13)
        let addressTextColor = UIColor.white.withAlphaComponent(0.8)
        let addressInsets = LayoutInsets(top: 0, left: 15, right: 15)
        let addressLineHeight: CGFloat = 15
        let addressBottomInset: CGFloat = 10

        let overlayViewColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        let timeFont = UIFont.wrfFont(ofSize: 13)
        let timeTextColor = UIColor.white.withAlphaComponent(0.8)
        let timeInsets = LayoutInsets(top: 0, left: 15, right: 15)
        let timeLineHeight: CGFloat = 15

        let visitorsFont = UIFont.wrfFont(ofSize: 13)
        let visitorsTextColor = UIColor.white.withAlphaComponent(0.8)
        let visitorsInsets = LayoutInsets(top: 0, left: 15, right: 15)
        let visitorsLineHeight: CGFloat = 15

        let timeSpacing: CGFloat = 5
        let visitorsSpacing: CGFloat = 5
        let topStackSpacing: CGFloat = 15

        let topStackInsets = LayoutInsets(top: 15, right: 15)

        let iconTintColor = UIColor.white.withAlphaComponent(0.8)
    }
}

final class ProfileBookingItemView: UIView {
    let appearance: Appearance

    var name: String? {
        didSet {
            self.nameLabel.attributedText = LineHeightStringMaker.makeString(
                self.name ?? "",
                editorLineHeight: self.appearance.nameEditorLineHeight,
                font: self.appearance.nameFont
            )
        }
    }

    var address: String? {
        didSet {
            self.addressLabel.attributedText = LineHeightStringMaker.makeString(
                self.address ?? "",
                editorLineHeight: self.appearance.addressLineHeight,
                font: self.appearance.addressFont
            )
        }
    }

    var date: String? {
        didSet {
            self.timeLabel.attributedText = LineHeightStringMaker.makeString(
                self.date ?? "",
                editorLineHeight: self.appearance.timeLineHeight,
                font: self.appearance.timeFont
            )
        }
    }

    var guests: Int = 0 {
        didSet {
            self.visitorsLabel.attributedText = LineHeightStringMaker.makeString(
                String(describing: self.guests),
                editorLineHeight: self.appearance.visitorsLineHeight,
                font: self.appearance.visitorsFont
            )
        }
    }

    var imageURL: URL? {
        didSet {
            guard let url = self.imageURL else {
                return
            }
            self.imageView.loadImage(from: url)
        }
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayViewColor
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameFont
        label.textColor = self.appearance.nameTextColor
        return label
    }()

    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.addressFont
        label.textColor = self.appearance.addressTextColor
        return label
    }()

    private lazy var timeIconImageView: UIImageView = {
        let image = #imageLiteral(resourceName: "booking-time").withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.iconTintColor
        return imageView
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.timeFont
        label.textColor = self.appearance.timeTextColor
        return label
    }()

    private lazy var timeStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.timeIconImageView, self.timeLabel])
        stack.spacing = self.appearance.timeSpacing
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()

    private lazy var visitorsIconImageView: UIImageView = {
        let image = #imageLiteral(resourceName: "booking-user").withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.iconTintColor
        return imageView
    }()

    private lazy var visitorsLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.visitorsFont
        label.textColor = self.appearance.visitorsTextColor
        return label
    }()

    private lazy var visitorsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.visitorsIconImageView, self.visitorsLabel])
        stack.spacing = self.appearance.visitorsSpacing
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()

    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.visitorsStackView, self.timeStackView])
        stack.axis = .horizontal
        stack.spacing = self.appearance.topStackSpacing
        stack.alignment = .center
        return stack
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
}

extension ProfileBookingItemView: ProgrammaticallyDesignable {
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.topStackView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.addressLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.topStackView.translatesAutoresizingMaskIntoConstraints = false
        self.topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.topStackInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.topStackInsets.right)
        }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.addressInsets.left)
            make.bottom.equalTo(self.addressLabel.snp.top)
        }

        self.addressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.addressInsets.left)
            make.bottom.equalTo(-self.appearance.addressBottomInset)
        }
    }
}
