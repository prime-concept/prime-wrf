import JTAppleCalendar
import UIKit

final class CalendarCell: JTAppleCell, Reusable {
    private lazy var itemView = CalendarItemView()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func update(with cellState: CellState) {
        self.isHidden = cellState.dateBelongsTo != .thisMonth
        self.itemView.update(with: cellState)
    }

    private func setupView() {
        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
