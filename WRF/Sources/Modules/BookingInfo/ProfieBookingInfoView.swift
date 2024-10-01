import SnapKit
import UIKit

protocol ProfileBookingInfoViewDelegate: AnyObject {
    func viewDidRequestBookingCancel()
}

extension ProfileBookingInfoView {
    struct Appearance: Codable {
        var headerHeight: CGFloat = 200
        var backgroundColor = Palette.shared.backgroundColor0

        var bookingInfoActionViewInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        // Reviews here always will be w/o reviews
        var reviewsInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        // header + summary height
        var cancelInsets: CGFloat = 252
    }
}

final class ProfileBookingInfoView: UIView {
    let appearance: Appearance

    weak var delegate: ProfileBookingInfoViewDelegate?

    var showCancel: Bool = false {
        didSet {
            if self.showCancel {
                self.addSubview(self.cancelView)
                self.cancelView.translatesAutoresizingMaskIntoConstraints = false
                self.cancelView.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(self.appearance.cancelInsets)
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalToSuperview()
                }
            } else {
                self.cancelView.removeFromSuperview()
            }
        }
    }

    var restaurantName: String? {
        didSet {
            self.cancelView.restaurantName = self.restaurantName
        }
    }

    private lazy var cancelView: BookingCancelView = {
        let view = BookingCancelView()
        view.cancelButton.addTarget(self, action: #selector(self.cancelClicked), for: .touchUpInside)
        view.resetButton.addTarget(self, action: #selector(self.resetClicked), for: .touchUpInside)
        return view
    }()

    private(set) lazy var scrollView = UIScrollView()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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

    // MARK: - Public API

    func addRowView(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }

    // MARK: - Private API

    @objc
    private func cancelClicked() {
        self.delegate?.viewDidRequestBookingCancel()
    }

    @objc
    private func resetClicked() {
        self.showCancel = false
    }
}

extension ProfileBookingInfoView: ProgrammaticallyDesignable {

    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
    }
    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.scrollView)
        }
    }
}
