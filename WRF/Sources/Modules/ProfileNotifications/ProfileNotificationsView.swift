import SnapKit
import UIKit

protocol ProfileNotificationsViewDelegate: AnyObject {
    func viewDidRequestNotificationsEnable(_ view: ProfileNotificationsView)
    func viewDidRequestNotificationsDisable(_ view: ProfileNotificationsView)
}

extension ProfileNotificationsView {
    struct Appearance {
        let stackViewTopOffset: CGFloat = 10
    }
}

final class ProfileNotificationsView: UIView {
    let appearance: Appearance

    weak var delegate: ProfileNotificationsViewDelegate?

    private lazy var emailItemView: ProfileNotificationsItemView = {
        let view = ProfileNotificationsItemView()
        view.title = "Новостная email рассылка"
        view.isHidden = true
        return view
    }()

    private lazy var notificationItemView: ProfileNotificationsItemView = {
        let view = ProfileNotificationsItemView()
        view.title = "Push-уведомления"
        view.onChange = { [weak self] newValue in
            guard let strongSelf = self else {
                return
            }
            if newValue {
                strongSelf.delegate?.viewDidRequestNotificationsEnable(strongSelf)
            } else {
                strongSelf.delegate?.viewDidRequestNotificationsDisable(strongSelf)
            }
        }
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.emailItemView, self.notificationItemView])
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

    func update(with model: ProfileNotificationsViewModel) {
        self.emailItemView.isSelected = model.isEmailEnabled
        self.notificationItemView.isSelected = model.isNotificationEnabled
    }
}

extension ProfileNotificationsView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.stackViewTopOffset)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
