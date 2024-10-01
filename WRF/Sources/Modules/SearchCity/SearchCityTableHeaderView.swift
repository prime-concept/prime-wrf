import UIKit
import SnapKit

class SearchCityTableHeaderView: UIView {

    // MARK: - constants

    private enum Appearance {
        static let labelInsets = LayoutInsets(top: 1, left: 20, bottom: -1, right: -20)
        static let titleLabelColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 0.6)
        static let titleFont = UIFont.wrfFont(ofSize: 11.0)

    }

    // MARK: - subviews

    let label: UILabel = {
        let label = UILabel()
        label.font = Appearance.titleFont
        label.textColor = Appearance.titleLabelColor
        return label
    }()

    // MARK: - life cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setups

    private func setupViews() {
        backgroundColor = .clear
        addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Appearance.labelInsets.left)
            make.trailing.equalToSuperview().offset(Appearance.labelInsets.right)
            make.top.equalToSuperview().offset(Appearance.labelInsets.top)
            make.bottom.equalToSuperview().offset(Appearance.labelInsets.bottom)
        }
    }

    func configure(with title: String) {
        label.text = title
    }
}
