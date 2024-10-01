import IQKeyboardManagerSwift
import SnapKit
import UIKit

protocol ProfileFeedbackViewControllerProtocol: BlockingLoaderPresentable {
    func showMessage(isSuccess: Bool)
    func showClientInfo(_ model: ProfileViewModel)
}

final class ProfileFeedbackViewController: UIViewController, UINavigationControllerDelegate {
    static let maximumImageCount = 5
    private static let animationDuration: TimeInterval = 0.25

    let presenter: ProfileFeedbackPresenterProtocol
    private lazy var feedbackView = ProfileFeedbackView()

    private var images: [UIImage] = []

    private var selectedImageIndex: Int?

    init(presenter: ProfileFeedbackPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(feedbackView)
        view.backgroundColorThemed = feedbackView.appearance.backgroundColor
        feedbackView.delegate = self
        feedbackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        self.navigationItem.title = "Обратная связь"
        self.navigationItem.setBackButtonText()

        self.presenter.loadClientInfo()
        self.feedbackView.updateCollectionView(delegate: self, dataSource: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }

    // MARK: - Private API

    private func showImagePickerController() {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        self.present(photoPicker, animated: true, completion: nil)
    }

    private func showImageEditPickerController() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Заменить", style: .default) { _ in
            self.showImagePickerController()
        }

        let storageAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            guard let index = self.selectedImageIndex else {
                return
            }
            self.images.remove(at: index)
            self.feedbackView.updateCollectionView(delegate: self, dataSource: self)
        }

        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(cameraAction); alert.addAction(storageAction); alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProfileFeedbackViewController: ProfileFeedbackViewControllerProtocol {
    func showMessage(isSuccess: Bool) {
        self.view.endEditing(true)

        let resultView = ProfileFeedbackCompletedActionView(result: isSuccess ? .success : .failure)
        resultView.alpha = 0.0
        resultView.onDismiss = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            UIView.animate(
                withDuration: type(of: strongSelf).animationDuration,
                animations: {
                    resultView.alpha = 0.0
                },
                completion: { _ in
                    resultView.removeFromSuperview()
                }
            )
        }

        self.view.addSubview(resultView)
        resultView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: type(of: self).animationDuration) {
            resultView.alpha = 1.0
        }
    }

    func showClientInfo(_ model: ProfileViewModel) {
        self.feedbackView.showClientInfo(model)
    }
}

extension ProfileFeedbackViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        feedbackView.appearance.itemSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let view: ProfileFeedbackImageAddFooterView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            for: indexPath
        )
        view.isHidden = self.images.count == ProfileFeedbackViewController.maximumImageCount
        view.delegate = self
        return view
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImageIndex = indexPath.row

        self.showImageEditPickerController()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        feedbackView.appearance.footerSize
    }
}

extension ProfileFeedbackViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: ProfileFeedbackScreenCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        if let image = self.images[safe: indexPath.row] {
            cell.image = image
        }
        return cell
    }
}

extension ProfileFeedbackViewController: ProfileFeedbackScreenAddViewDelegate {
    func viewDidRequestImageAdd() {
        guard self.images.count < ProfileFeedbackViewController.maximumImageCount else {
            return
        }
        self.showImagePickerController()
    }
}

extension ProfileFeedbackViewController: ProfileFeedbackViewDelegate {
    func viewDidSubmitAppFeedback() {
        self.presenter.submit(model: feedbackView.makeViewModel(images: self.images))
    }

    func viewDidEnterInvalidEmail() {
        let alert = UIAlertController(
            title: "Некорректная почта",
            message: "Введите корректный почтовый адрес",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default)

        alert.addAction(okAction)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
}


extension ProfileFeedbackViewController: UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            guard let index = self.selectedImageIndex else {
                self.images.append(image)
                self.feedbackView.updateCollectionView(delegate: self, dataSource: self)

                picker.dismiss(animated: true)
                return
            }
            self.images[index] = image
            self.selectedImageIndex = nil
            self.feedbackView.updateCollectionView(delegate: self, dataSource: self)
        }
        picker.dismiss(animated: true)
    }
}
