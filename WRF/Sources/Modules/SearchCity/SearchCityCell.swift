import SnapKit
import UIKit

final class SearchCityCell: UITableViewCell, Reusable {

    private enum Appearance {
        static let backgroundColor = UIColor(red: 0.16, green: 0.16, blue: 0.2, alpha: 1.0)
        static let padding: CGFloat = 20.0
        static let innerOffset: CGFloat = 10.0
        static let titleLabelColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 1)
        static let titleFont = UIFont.wrfFont(ofSize: 15.0)
        static let distanceLabelColor = UIColor(red: 0.89, green: 0.9, blue: 0.9, alpha: 0.6)
        static let distanceFont = UIFont.wrfFont(ofSize: 12.0)
    }

    // MARK: - subviews

    private lazy var titleLabel = {
        let label = UILabel()
        label.textColor = Appearance.titleLabelColor
        label.font = Appearance.titleFont
        return label
    }()

    private lazy var distanceLabel = {
        let label = UILabel()
        label.textColor = Appearance.distanceLabelColor
        label.font = Appearance.distanceFont
        return label
    }()

    private lazy var checkmarkImageView = {
        let imageView = UIImageView(image: UIImage(named: "map-checkmark-icon"))
        return imageView
    }()

    // MARK: - life cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setups

    func setup(with viewModel: SearchCityCellViewModel) {
        titleLabel.text = viewModel.title
        distanceLabel.text = viewModel.distance
        distanceLabel.isHidden = viewModel.isCheckmarkVisible
        checkmarkImageView.isHidden = !viewModel.isCheckmarkVisible
    }

    // MARK: - configure

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(checkmarkImageView)

        // Configure views
        backgroundColor = Appearance.backgroundColor
        checkmarkImageView.isHidden = true
        distanceLabel.isHidden = true
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Appearance.padding)
            make.trailing.equalTo(distanceLabel.snp.leading).offset(Appearance.innerOffset)
            make.centerY.equalToSuperview()
        }
        distanceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Appearance.padding)
            make.centerY.equalToSuperview()
        }
        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Appearance.padding)
            make.centerY.equalToSuperview()
        }
    }
}
