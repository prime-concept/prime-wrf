import SnapKit
import UIKit

extension FeedbackView {
    struct Appearance {
        let confirmationButtonFont = UIFont.wrfFont(ofSize: 14)
        let confirmationButtonHeight: CGFloat = 40
        let confirmationButtonInsets = LayoutInsets(left: 15, bottom: 21, right: 15)

        var confirmationButtonBackgroundColor = UIColor.black
        let confirmationButtonTextColor = UIColor.white
        let confirmationButtonCornerRadius: CGFloat = 8
    }
}

final class FeedbackView: UIView {
    let appearance: Appearance

    weak var delegate: FeedbackViewDelegate?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private(set) lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()

    private lazy var feedbackRateView: FeedbackRateView = {
        let view = FeedbackRateView()
        view.starsRatingView.delegate = self
        return view
    }()

    private lazy var feedbackTagsView = FeedbackTagsView()
    private lazy var feedbackReviewView = FeedbackReviewView()
    private lazy var feedbackAgreementView = FeedbackAgreementView()

    private(set) lazy var confirmationButton: UIControl = {
        let button = UIButton(type: .system)
        button.setTitle("Отправить", for: .normal)
        button.titleLabel?.font = self.appearance.confirmationButtonFont
        button.backgroundColor = self.appearance.confirmationButtonBackgroundColor
        button.setTitleColor(self.appearance.confirmationButtonTextColor, for: .normal)
        button.addTarget(self, action: #selector(self.confirmationClicked), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = self.appearance.confirmationButtonCornerRadius
        return button
    }()

    var placeName: String? {
        didSet {
            self.feedbackRateView.restaurantName = self.placeName
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = ApplicationAppearance.appearance()
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

    // MARK: - Private API

    @objc
    private func hideKeyboard() {
        self.endEditing(true)
    }

    @objc
    private func confirmationClicked() {
        let viewModel = FeedbackViewModel(
            review: self.feedbackReviewView.textView.text,
            assessment: self.feedbackRateView.starsRatingView.starsCount,
            publish: self.feedbackAgreementView.checkboxControl.isSelected,
            improve: self.feedbackTagsView.selectedTags
        )
        self.delegate?.feedbackViewDidConfirm(viewModel)
    }
}

extension FeedbackView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)

        // Content
        self.stackView.addArrangedSubview(self.feedbackRateView)
        self.stackView.addArrangedSubview(self.feedbackTagsView)
        self.stackView.addArrangedSubview(self.feedbackReviewView)
        self.stackView.addArrangedSubview(self.feedbackAgreementView)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.scrollView)
        }
    }
}

extension FeedbackView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.feedbackReviewView.textView.endEditing(true)
    }
}

extension FeedbackView: StarsRatingViewDelegate {
    func ratingViewDidSelectRating(_ view: StarsRatingView) {
        self.feedbackTagsView.rating = view.starsCount
    }
}
