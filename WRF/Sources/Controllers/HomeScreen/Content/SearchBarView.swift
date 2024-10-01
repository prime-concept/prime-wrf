import SnapKit
import UIKit

final class SearchBarView: UIView {

    // MARK: - constants

    private enum Constants {
        static let topOffset: CGFloat = 8.0
        static let backgroundColor = UIColor(red: 0.16, green: 0.16, blue: 0.2, alpha: 0.5)
        static let buttonBorderColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 0.5)
        static let buttonBorder: CGFloat = 1.0

        static let cityButtonBorderColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 0.5)
        static let cityButtonFontColor = UIColor(red: 0.24, green: 0.25, blue: 0.29, alpha: 1.0)
        static let cityButtonFont = UIFont.wrfFont(ofSize: 14.0)
        static let cityButtonSize = CGSize(width: 100, height: 32)
        static let cityButtonInsets = LayoutInsets(top: 2.0, left: 2.0, bottom: -2.0)

        static let searchButtonInsets = LayoutInsets(top: 2.0, left: 12.0, bottom: -2.0, right: -2.0)
        static let searchButtonFont = UIFont.wrfFont(ofSize: 14.0)
        static let searchButtonTitleColor = UIColor(red: 0.91, green: 0.92, blue: 0.92, alpha: 1)

        static let navButtonBorder: CGFloat = 1.0
        static let navButtonBackgroundColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 0.5)
        static let navButtonBorderColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 0.5)
        static let navButtonInsets = LayoutInsets(top: 2.0, bottom: -2.0, right: -2.0)
        static let navButtonSize = CGSize(width: 38, height: 32)
    }

    // MARK: - subviews

    private lazy var cityButton: UIButton = {
        let button = RightImageButton()
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.backgroundColor = .white
        button.layer.borderWidth = Constants.buttonBorder
        button.layer.borderColor = Constants.cityButtonBorderColor.cgColor
        button.setTitleColor(Constants.cityButtonFontColor, for: .normal)
        button.layer.cornerRadius = 4.0
        button.titleLabel?.font = Constants.cityButtonFont
        button.setImage(UIImage(named: "ArrowDown"), for: .normal)
        button.setTitle("Город", for: .normal)
        button.addTarget(self, action: #selector(cityButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Поиск", for: .normal)
        button.setTitleColor(Constants.searchButtonTitleColor, for: .normal)
        button.titleLabel?.font = Constants.searchButtonFont
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var navButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "Geo"), for: .normal)
        button.addTarget(self, action: #selector(navButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - callbacks

    var cityButtonTappedClosure: (() -> Void)?
    var searchButtonTappedClosure: (() -> Void)?
    var navButtonTappedClosure: (() -> Void)?

    // MARK: - life cycle

    init() {
        super.init(frame: .zero)
        setupView()
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setup

    func setupCityButton(title: String) {
        cityButton.setTitle(title, for: .normal)
        let textWidth = title.size(withAttributes: [NSAttributedString.Key.font: Constants.cityButtonFont]).width
        let buttonWidth = textWidth + Constants.cityButtonInsets.left + Constants.cityButtonInsets.right
        cityButton.snp.updateConstraints { make in
            make.width.equalTo(buttonWidth)
        }
        layoutIfNeeded()
    }

    // MARK: - actions

    @objc
    private func cityButtonTapped() {
        cityButtonTappedClosure?()
    }

    @objc
    private func searchButtonTapped() {
        cityButtonTappedClosure?()
    }

    @objc
    private func navButtonTapped() {
        navButtonTappedClosure?()
    }

    // MARK: - layout

    private func setupView() {
        backgroundColor = Constants.backgroundColor
    }

    private func setupSubviews() {
        addSubview(cityButton)
        addSubview(searchButton)
        addSubview(navButton)
    }

    private func setupConstraints() {
        cityButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.cityButtonInsets.top)
            make.leading.equalToSuperview().offset(Constants.cityButtonInsets.left)
            make.bottom.equalToSuperview().offset(Constants.cityButtonInsets.bottom)
            make.width.equalTo(Constants.cityButtonSize.width)
        }
        searchButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.searchButtonInsets.top)
            make.leading.equalTo(cityButton.snp.trailing).offset(Constants.searchButtonInsets.left)
            make.bottom.equalToSuperview().offset(Constants.searchButtonInsets.bottom)
            make.trailing.equalTo(navButton.snp.leading).offset(Constants.searchButtonInsets.right)
        }
        navButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-Constants.navButtonInsets.top)
            make.bottom.equalToSuperview().offset(-Constants.navButtonInsets.bottom)
            make.trailing.equalToSuperview().offset(-Constants.navButtonInsets.right)
            make.width.equalTo(Constants.navButtonSize.width)
        }
    }
}
