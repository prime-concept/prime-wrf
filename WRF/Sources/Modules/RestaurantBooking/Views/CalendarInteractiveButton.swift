import SnapKit
import UIKit

final class CalendarInteractiveButton: UIButton {
    private var isInitialized = false

    private lazy var dateLabel = UILabel()

    // swiftlint:disable:next implicitly_unwrapped_optional
    override var tintColor: UIColor! {
        didSet {
            self.dateLabel.textColor = self.tintColor
        }
    }

    private let dateFont = UIFont.wrfFont(
        ofSize: 14,
        weight: .semibold
    )

    var date = Date() {
        didSet {
            if self.isInitialized {
                self.updateDate()
            }
        }
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        // Do nothing
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !self.isInitialized {
            self.isInitialized = true
            self.setImage(UIImage(named: "calendar-empty"), for: .normal)
            self.setupView()

            DispatchQueue.main.async {
                self.updateDate()
            }
        }
    }

    private func setupView() {
        self.addSubview(self.dateLabel)
        self.dateLabel.snp.makeConstraints { make in
            // Magic offset, do not change
            make.centerY.equalToSuperview().offset(2)
            make.centerX.equalToSuperview()
        }

        self.dateLabel.font = self.dateFont
    }

    private func updateDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        let dayNum = formatter.string(from: self.date)
        self.dateLabel.text = dayNum
        self.dateLabel.textColor = self.tintColor
    }
}
