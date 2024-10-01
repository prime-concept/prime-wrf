import SnapKit
import UIKit

final class HomeScreenSearchBarView: UIView {

    struct Appearance {
        var topOffset: CGFloat = 8.0

        var backgroundColor = Palette.shared.backgroundColor0.withAlphaComponent(0.5)

        var cityButtonOffset = LayoutInsets(top: 2.0, left: 2.0, bottom: -2.0)

        var textFieldFont = UIFont.wrfFont(ofSize: 14.0)
        var textFieldLineHeight: CGFloat = 16.09

        var searchButtonInsets = LayoutInsets(top: 2.0, left: 12.0, bottom: 2.0, right: 2.0)
        var searchButtonFont = UIFont.wrfFont(ofSize: 14.0)
        var searchButtonTitleColor = Palette.shared.textPrimaryInverse
        var textFieldTextColor = Palette.shared.textPrimary
        var currentLocationButtonBorder: CGFloat = 1.0

        var cursorColor = Palette.shared.iconsBrand

        var currentLocationButtonInsets = LayoutInsets(top: 2.0, bottom: -2.0, right: -2.0)
        var currentLocationButtonSize = CGSize(width: 38.0, height: 32.0)
        var searchBarViewCornerRadius: CGFloat = 6.0
    }

    // MARK: - subviews

    private lazy var cityButton: MapDropdownButtonView = {
        let button = MapDropdownButtonView(
            appearance: .init(contentInsets: UIEdgeInsets(top: 8, left: 28, bottom: 8, right: 28))
        )
        button.addTapHandler { [weak self] in
            self?.cityButtonTapped()
        }
        button.update(with: .init(title: "Город"))

        // https://jira.lgn.me/browse/MOBBREND-2341
        // TODO: remove this line to show the city button
        button.isHidden = true
        return button
    }()

    private lazy var searchFieldTapGesture = UITapGestureRecognizer(target: self, action: #selector(searchFieldTapped))
    private lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.font = appearance.textFieldFont
        textField.textColorThemed = appearance.textFieldTextColor
        textField.tintColorThemed = appearance.cursorColor
        textField.clearButtonMode = .whileEditing
        textField.attributedPlaceholder = LineHeightStringMaker.makeString(
            "Поиск", 
            editorLineHeight: appearance.textFieldLineHeight,
            font: appearance.textFieldFont,
            alignment: .left
        )

        return textField
    }()

    private lazy var currentLocationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "map-location-icon"), for: .normal)
        button.addTarget(self, action: #selector(currentLocationDidTapButton), for: .touchUpInside)
        return button
    }()

    // MARK: - callbacks

    var cityButtonTapAction: (() -> Void)?
    var searchFieldTapAction: (() -> Void)?
    var currentLocationButtonTapAction: (() -> Void)?

    // MARK: - life cycle

    let appearance: Appearance

    init(appearance: Appearance = .init()) {
        self.appearance = appearance

        super.init(frame: .zero)

        setupView()
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setups

    func setupSearchFieldTapAction(enabled: Bool) {
        enabled
            ? searchField.addGestureRecognizer(searchFieldTapGesture)
            : searchField.removeGestureRecognizer(searchFieldTapGesture)
    }

    func setupSearchField(text: String) {
        searchField.text = text
    }

    func setupSearchField(delegate: UITextFieldDelegate) {
        searchField.delegate = delegate
    }

    func setupCityButton(with title: String) {
        cityButton.update(with: .init(title: title))
    }

    // MARK: - actions

    @objc
    private func cityButtonTapped() {
        cityButtonTapAction?()
    }

    @objc
    private func searchFieldTapped() {
        searchFieldTapAction?()
    }

    @objc
    private func currentLocationDidTapButton() {
        currentLocationButtonTapAction?()
    }

    // MARK: - layout

    private func setupView() {
        layer.cornerRadius = appearance.searchBarViewCornerRadius
        clipsToBounds = true
        backgroundColorThemed = appearance.backgroundColor
    }

    private func setupSubviews() {
        addSubview(cityButton)
        addSubview(searchField)
        addSubview(currentLocationButton)
    }

    private func setupConstraints() {
        cityButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(appearance.cityButtonOffset.top)
            make.leading.equalToSuperview().offset(appearance.cityButtonOffset.left)
            make.bottom.equalToSuperview().offset(appearance.cityButtonOffset.bottom)
        }
        searchField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(appearance.searchButtonInsets.top)
            // https://jira.lgn.me/browse/MOBBREND-2341
            // TODO: uncomment this line and remove the next one to show the city button
            // make.leading.equalTo(cityButton.snp.trailing).offset(appearance.searchButtonInsets.left)
            make.leading.equalToSuperview().offset(appearance.searchButtonInsets.left)
            make.bottom.equalToSuperview().offset(-appearance.searchButtonInsets.bottom)
            make.trailing.equalTo(currentLocationButton.snp.leading).offset(appearance.searchButtonInsets.right)
        }
        currentLocationButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-appearance.currentLocationButtonInsets.top)
            make.bottom.equalToSuperview().offset(-appearance.currentLocationButtonInsets.bottom)
            make.trailing.equalToSuperview().offset(-appearance.currentLocationButtonInsets.right)
            make.width.equalTo(appearance.currentLocationButtonSize.width)
        }
    }
}
