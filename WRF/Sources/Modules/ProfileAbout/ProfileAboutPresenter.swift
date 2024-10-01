import UIKit

protocol ProfileAboutPresenterProtocol { }

final class ProfileAboutPresenter: ProfileAboutPresenterProtocol {
    weak var viewController: ProfileAboutViewControllerProtocol?
}