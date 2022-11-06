import UIKit
import Shared
import Countries
import Permissions
import MenuFeature
import Presentation

public protocol ProfileCoordinating {
    func toEmail(from: UIViewController)
    func toPhone(from: UIViewController)
    func toPhotos(from: UIViewController)
    func toSideMenu(from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
    func toPermission(type: PermissionType, from: UIViewController)

    func toCountries(
        from: UIViewController,
        _: @escaping (Country) -> Void
    )
}

public struct ProfileCoordinator: ProfileCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var modalPresenter: Presenting = ModalPresenter()
    var sidePresenter: Presenting = SideMenuPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var emailFactory: () -> UIViewController
    var phoneFactory: () -> UIViewController
    var imagePickerFactory: () -> UIImagePickerController
    var permissionFactory: () -> RequestPermissionController
    var sideMenuFactory: (MenuItem, UIViewController) -> UIViewController
    var countriesFactory: (@escaping (Country) -> Void) -> UIViewController

    public init(
        emailFactory: @escaping () -> UIViewController,
        phoneFactory: @escaping () -> UIViewController,
        imagePickerFactory: @escaping () -> UIImagePickerController,
        permissionFactory: @escaping () -> RequestPermissionController, // ⚠️
        sideMenuFactory: @escaping (MenuItem, UIViewController) -> UIViewController,
        countriesFactory: @escaping (@escaping (Country) -> Void) -> UIViewController
    ) {
        self.emailFactory = emailFactory
        self.phoneFactory = phoneFactory
        self.sideMenuFactory = sideMenuFactory
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

    func toPermission(type: PermissionType, from parent: UIViewController) {
        let screen = permissionFactory()
        screen.setup(type: type)
        pushPresenter.present(screen, from: parent)
    }

    func toDrawer(_ drawer: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(drawer, from: parent)
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

    func toSideMenu(from parent: UIViewController) {
        let screen = sideMenuFactory(.profile, parent)
        sidePresenter.present(screen, from: parent)
    }
}
