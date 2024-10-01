import UIKit

final class RestaurantSpacingView: UIView {
    private let height: CGFloat

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.height)
    }

    init(frame: CGRect = .zero, height: CGFloat) {
        self.height = height
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}
