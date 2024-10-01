import SnapKit

protocol ProfileFeedbackScreenAddViewDelegate: AnyObject {
    func viewDidRequestImageAdd()
}

final class ProfileFeedbackImageAddFooterView: UICollectionReusableView, Reusable {
    weak var delegate: ProfileFeedbackScreenAddViewDelegate?

    private lazy var imageAddView = ProfileFeedbackImageAddView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private API

    @objc
    private func imageAddViewClicked() {
        self.delegate?.viewDidRequestImageAdd()
    }
}

extension ProfileFeedbackImageAddFooterView: ProgrammaticallyDesignable {
    public func setupView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageAddViewClicked))
        self.imageAddView.addGestureRecognizer(tap)
    }

    public func addSubviews() {
        self.addSubview(self.imageAddView)
    }

    public func makeConstraints() {
        self.imageAddView.translatesAutoresizingMaskIntoConstraints = false
        self.imageAddView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
