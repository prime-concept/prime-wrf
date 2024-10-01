import UIKit

final class CountryCodeItemView: UIView {
	private static let defaultColor = UIColor.black
    private static let selectedColor = UIColor.black

	private static let lightFont = UIFont.wrfFont(ofSize: 15, weight: .light)
	private static let regularFont = UIFont.wrfFont(ofSize: 15, weight: .regular)

    private lazy var flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
		imageView.layer.cornerRadius = 2
		imageView.layer.borderWidth = 1 / UIScreen.main.scale
		imageView.layer.borderColor = UIColor(hex: 0x949494).cgColor
		imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Self.defaultColor
		label.font = Self.regularFont
        return label
    }()

    private lazy var countryNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Self.defaultColor
		label.font = Self.lightFont
        return label
    }()

    private lazy var selectedIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon-checkmark"))
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
		imageView.tintColor = UIColor(hex: 0x949494)
		imageView.make(.size, .equal, [12, 9])
        return imageView
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
		view.backgroundColor = UIColor(hex: 0xE5E5E5)
        return view
    }()

    var flag: UIImage? {
        didSet {
            self.flagImageView.image = self.flag
        }
    }

    var code: String? {
        didSet {
            self.codeLabel.text = self.code
        }
    }

    var countryName: String? {
        didSet {
            self.countryNameLabel.text = self.countryName
        }
    }

    var isSelected: Bool = false {
        didSet {
            self.selectedIconImageView.isHidden = !self.isSelected
        }
    }

    init() {
        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateAppearance() {
        self.codeLabel.textColor = self.isSelected ? Self.selectedColor : Self.defaultColor
        self.countryNameLabel.textColor = self.isSelected ? Self.selectedColor : Self.defaultColor

		self.countryNameLabel.font = self.isSelected ? Self.regularFont : Self.lightFont
    }
}

extension CountryCodeItemView {
    func setupView() {
    }

    func addSubviews() {
        [
            self.flagImageView,
            self.codeLabel,
            self.countryNameLabel,
            self.selectedIconImageView,
            self.lineView
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.flagImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24, height: 16))
            make.leading.equalToSuperview().inset(20)
        }

		self.codeLabel.make(.leading, .equal, to: .trailing, of: self.flagImageView, +10)
		self.countryNameLabel.make(.leading, .equal, to: .trailing, of: self.flagImageView, +57)

        self.selectedIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(30)
        }

		[self.flagImageView, self.codeLabel, self.countryNameLabel, self.selectedIconImageView].forEach {
			$0.make(.centerY, .equalToSuperview)
		}

		self.lineView.make([.leading, .trailing, .bottom], .equalToSuperview, [15, -15, 0])
		self.lineView.make(.height, .equal, 1)
    }
}
