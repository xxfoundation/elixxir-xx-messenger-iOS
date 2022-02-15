import UIKit
import Models
import Shared
import QuickLook
import Presentation
import Permissions

public protocol ChatCoordinating {
    func toCamera(from: UIViewController)
    func toLibrary(from: UIViewController)
    func toPreview(from: UIViewController)
    func toPermission(type: PermissionType, from: UIViewController)
    func toWebview(with: String, from: UIViewController)

    func toRetrySheet(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toMenuSheet(_: UIViewController, from: UIViewController)
    func toMembersList(_: UIViewController, from: UIViewController)
}

public struct ChatCoordinator: ChatCoordinating {
    public init(
        retryFactory: @escaping () -> UIViewController,
        contactFactory: @escaping (Contact) -> UIViewController
    ) {
        self.retryFactory = retryFactory
        self.contactFactory = contactFactory
    }

    // MARK: Presenters

    var pusher: Presenting = PushPresenter()
    var presenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    // MARK: Factories

    var webFactory: (String) -> UIViewController = WebScreen.init(url:)

    var retryFactory: () -> UIViewController
    var contactFactory: (Contact) -> UIViewController

    var previewFactory: () -> QLPreviewController = QLPreviewController.init
    var permissionFactory: () -> RequestPermissionController = RequestPermissionController.init
    var imagePickerFactory: () -> UIImagePickerController = UIImagePickerController.init
}

public extension ChatCoordinator {
    func toWebview(
        with urlString: String,
        from parent: UIViewController
    ) {
        let screen = webFactory(urlString)
        presenter.present(screen, from: parent)
    }

    func toPermission(type: PermissionType, from parent: UIViewController) {
        let screen = permissionFactory()
        screen.setup(type: type)
        pusher.present(screen, from: parent)
    }

    func toMembersList(
        _ screen: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(screen, from: parent)
    }

    func toPopup(
        _ popup: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(popup, from: parent)
    }

    func toContact(
        _ contact: Contact,
        from parent: UIViewController
    ) {
        let screen = contactFactory(contact)
        pusher.present(screen, from: parent)
    }

    func toMenuSheet(
        _ screen: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(screen, from: parent)
    }

    func toRetrySheet(from parent: UIViewController) {
        let screen = retryFactory()
        bottomPresenter.present(screen, from: parent)
    }

    func toLibrary(from parent: UIViewController) {
        let screen = imagePickerFactory()
        screen.delegate = (parent as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
        screen.allowsEditing = false
        presenter.present(screen, from: parent)
    }

    func toCamera(from parent: UIViewController) {
        let screen = imagePickerFactory()
        screen.delegate = (parent as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
        screen.sourceType = .camera
        screen.allowsEditing = false
        presenter.present(screen, from: parent)
    }

    func toPreview(from parent: UIViewController) {
        let screen = previewFactory()
        screen.delegate = (parent as? QLPreviewControllerDelegate)
        screen.dataSource = (parent as? QLPreviewControllerDataSource)
        pusher.present(screen, from: parent)
    }
}
