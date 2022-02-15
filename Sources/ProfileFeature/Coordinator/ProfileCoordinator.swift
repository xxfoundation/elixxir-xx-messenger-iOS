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
    public init() {}

    var pusher: Presenting = PushPresenter()
    var presenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    // MARK: Factories

    var emailFactory: () -> UIViewController
        = ProfileEmailController.init

    var phoneFactory: () -> UIViewController
        = ProfilePhoneController.init

    var imagePickerFactory: () -> UIImagePickerController
        = UIImagePickerController.init

    var permissionFactory: () -> RequestPermissionController = RequestPermissionController.init

    var countriesFactory: (@escaping (Country) -> Void) -> UIViewController
        = CountryListController.init(_:)

    var codeFactory: (AttributeConfirmation, @escaping ControllerClosure) -> UIViewController
        = ProfileCodeController.init(_:_:)
}

public extension ProfileCoordinator {
    func toPermission(type: PermissionType, from parent: UIViewController) {
        let screen = permissionFactory()
        screen.setup(type: type)
        pusher.present(screen, from: parent)
    }

    func toPopup(
        _ popup: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(popup, from: parent)
    }

    func toPhotos(from parent: UIViewController) {
        let screen = imagePickerFactory()
        screen.delegate = (parent as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
        screen.allowsEditing = true
        presenter.present(screen, from: parent)
    }

    func toEmail(from parent: UIViewController) {
        let screen = emailFactory()
        pusher.present(screen, from: parent)
    }

    func toPhone(from parent: UIViewController) {
        let screen = phoneFactory()
        pusher.present(screen, from: parent)
    }

    func toCode(
        with confirmation: AttributeConfirmation,
        from parent: UIViewController,
        _ completion: @escaping ControllerClosure
    ) {
        let screen = codeFactory(confirmation, completion)
        pusher.present(screen, from: parent)
    }

    func toCountries(
        from parent: UIViewController,
        _ onChoose: @escaping (Country) -> Void
    ) {
        let screen = countriesFactory(onChoose)
        pusher.present(screen, from: parent)
    }
}
