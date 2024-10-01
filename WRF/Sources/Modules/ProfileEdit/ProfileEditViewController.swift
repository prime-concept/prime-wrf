import UIKit

protocol ProfileEditViewControllerProtocol: AnyObject {
    func showClientInfo(_ model: ProfileViewModel)
}

final class ProfileEditViewController: UIViewController {
    let presenter: ProfileEditPresenterProtocol
    lazy var profileEditView = ProfileEditView(frame: UIScreen.main.bounds)

    weak var delegate: ProfileSettingsDelegate?

    init(presenter: ProfileEditPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Редактирование"

        view.addSubview(profileEditView)
        profileEditView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        view.backgroundColorThemed = profileEditView.appearance.backgroundColor

        profileEditView.delegate = self

        self.presenter.loadClientInfo()
    }

    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            self.presenter.isProfileChanged(model: profileEditView.makeViewModel()).done { isChanged in
                if isChanged {
                    self.delegate?.didRequestProfileUpdate(viewModel: self.profileEditView.makeViewModel())
                }
            }
        }
    }

    // MARK: - Private api

    private func showImagePickerController() {
        let alert = UIAlertController(title: "Выбрать", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Камера", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let photoPicker = UIImagePickerController()
                photoPicker.delegate = self
                photoPicker.sourceType = .camera
                self.present(photoPicker, animated: true, completion: nil)
            }
        }
        let storageAction = UIAlertAction(title: "Галерея", style: .default) { _ in
            let photoPicker = UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.sourceType = .photoLibrary
            self.present(photoPicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(cameraAction); alert.addAction(storageAction); alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProfileEditViewController: ProfileEditViewControllerProtocol {
    func showClientInfo(_ model: ProfileViewModel) {
        self.profileEditView.showClientInfo(model)
    }
}

extension ProfileEditViewController: ProfileEditViewDelegate {
    func profileEditViewDidRequestAvatarChange(_ view: ProfileEditView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let update = UIAlertAction(title: "Заменить", style: .default) { _ in
            self.showImagePickerController()
        }
        let remove = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.profileEditView.updateClientPhoto(nil)
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(update); alert.addAction(remove); alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true)
    }

    func profileEditViewShowDisabledDateChangeAlert(_ view: ProfileEditView) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Для изменения даты рождения обратитесь в техническую поддержку",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        self.present(alert, animated: true)
    }
}

extension ProfileEditViewController: UINavigationControllerDelegate { }

extension ProfileEditViewController: UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
       didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            self.profileEditView.updateClientPhoto(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
