import UIKit
import Shared
import Models
import Countries
import Presentation
import Permissions

public protocol ProfileCoordinating {
    func toEmail(from: UIViewController)
    func toPhone(from: UIViewController)
    func toPhotos(from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toPermission(type: PermissionType, from: UIViewController)

    func toCode(
        with: AttributeConfirmation,
        from: UIViewController,
        _: @escaping ControllerClosure
    )

    func toCountries(
        from: UIViewController,
        _: @escaping (Country) -> Void
    )
}

public struct ProfileCoordinator: ProfileCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var modalPresenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var emailFactory: () -> UIViewController
    var phoneFactory: () -> UIViewController
    var imagePickerFactory: () -> UIImagePickerController
    var permissionFactory: () -> RequestPermissionController
    var countriesFactory: (@escaping (Country) -> Void) -> UIViewController
    var codeFactory: (AttributeConfirmation, @escaping ControllerClosure) -> UIViewController

    public init(
        emailFactory: @escaping () -> UIViewController,
        phoneFactory: @escaping () -> UIViewController,
        imagePickerFactory: @escaping () -> UIImagePickerController,
        permissionFactory: @escaping () -> RequestPermissionController, // ⚠️
        countriesFactory: @escaping (@escaping (Country) -> Void) -> UIViewController,
        codeFactory: @escaping (AttributeConfirmation, @escaping ControllerClosure) -> UIViewController
    ) {
        self.codeFactory = codeFactory
        self.emailFactory = emailFactory
        self.phoneFactory = phoneFactory
        self.countriesFactory = countriesFactory
        self.permissionFactory = permissionFactory
        self.imagePickerFactory = imagePickerFactory
    }
}

public extension ProfileCoordinator {
    func toEmail(from parent: UIViewController) {
        let screen = emailFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toPhone(from parent: UIViewController) {
        let screen = phoneFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toCode(
        with confirmation: AttributeConfirmation,
        from parent: UIViewController,
        _ completion: @escaping ControllerClosure
    ) {
        let screen = codeFactory(confirmation, completion)
        pushPresenter.present(screen, from: parent)
    }

    func toPermission(type: PermissionType, from parent: UIViewController) {
        let screen = permissionFactory()
        screen.setup(type: type)
        pushPresenter.present(screen, from: parent)
    }

    func toPopup(_ popup: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(popup, from: parent)
    }

    func toCountries(from parent: UIViewController, _ onChoose: @escaping (Country) -> Void) {
        let screen = countriesFactory(onChoose)
        pushPresenter.present(screen, from: parent)
    }

    func toPhotos(from parent: UIViewController) {
        let screen = imagePickerFactory()
        screen.delegate = (parent as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
        screen.allowsEditing = true
        modalPresenter.present(screen, from: parent)
    }
}
