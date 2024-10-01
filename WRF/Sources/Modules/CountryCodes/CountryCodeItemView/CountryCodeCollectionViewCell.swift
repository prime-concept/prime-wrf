import UIKit

final class CountryCodeCollectionViewCell: UICollectionViewCell, Reusable {
    private var countryCodeItemView = CountryCodeItemView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                countryCodeItemView.isSelected = true
                countryCodeItemView.updateAppearance()
            } else {
                countryCodeItemView.isSelected = false
                countryCodeItemView.updateAppearance()
            }
        }
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.addSubview(self.countryCodeItemView)
    }

    private func makeConstraints() {
        self.countryCodeItemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setup(with item: CountryCode) {
        self.countryCodeItemView.flag = item.flagImage
        self.countryCodeItemView.code = item.countryCodeDisplayable
        self.countryCodeItemView.countryName = item.countryName
        self.isSelected = item.isSelected
    }
}
