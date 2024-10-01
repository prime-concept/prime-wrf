import SnapKit
import UIKit

extension AuthSignInView {
    struct Appearance {
        let textFieldHeight: CGFloat = 55
    }
}

final class AuthSignInView: UIView {
    let appearance: Appearance

	var onCountrySelectionRequested: (() -> Void)?

	private(set) lazy var phoneTextField: PhoneTextField = {
		let title = "Телефон"
		let textField = PhoneTextField()
		textField.placeholder = title
		textField.title = title
		textField.keyboardType = .phonePad
		return textField
	}()

    private lazy var confirmationView: AuthConfirmationControlsView = {
        let view = AuthConfirmationControlsView()
        view.isTermsEnabled = false
        return view
    }()

    var submitButton: UIControl {
        return self.confirmationView.submitButton
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.textFieldHeight + self.confirmationView.intrinsicContentSize.height
        )
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    func showError(message: String) {
        self.phoneTextField.errorMessage = message
    }
}

extension AuthSignInView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.phoneTextField)
        self.addSubview(self.confirmationView)
    }

    func makeConstraints() {
        self.phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        self.phoneTextField.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.textFieldHeight)
        }

        self.confirmationView.translatesAutoresizingMaskIntoConstraints = false
        self.confirmationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.phoneTextField.snp.bottom)
        }
    }
}
