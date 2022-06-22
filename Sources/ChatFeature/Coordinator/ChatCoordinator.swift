import UIKit
import Models
import Shared
import QuickLook
import Permissions
import Presentation
import XXModels

public protocol ChatCoordinating {
    func toCamera(from: UIViewController)
    func toLibrary(from: UIViewController)
    func toPreview(from: UIViewController)
    func toRetrySheet(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toWebview(with: String, from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
    func toMenuSheet(_: UIViewController, from: UIViewController)
    func toPermission(type: PermissionType, from: UIViewController)
    func toMembersList(_: UIViewController, from: UIViewController)
}

public struct ChatCoordinator: ChatCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var modalPresenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var retryFactory: () -> UIViewController
    var webFactory: (String) -> UIViewController
    var previewFactory: () -> QLPreviewController
    var contactFactory: (Contact) -> UIViewController
    var imagePickerFactory: () -> UIImagePickerController
    var permissionFactory: () -> RequestPermissionController

    public init(
        retryFactory: @escaping () -> UIViewController,
        webFactory: @escaping (String) -> UIViewController,
        previewFactory: @escaping () -> QLPreviewController,
        contactFactory: @escaping (Contact) -> UIViewController,
        imagePickerFactory: @escaping () -> UIImagePickerController,
        permissionFactory: @escaping () -> RequestPermissionController
    ) {
        self.webFactory = webFactory
        self.retryFactory = retryFactory
        self.previewFactory = previewFactory
        self.contactFactory = contactFactory
        self.permissionFactory = permissionFactory
        self.imagePickerFactory = imagePickerFactory
    }
}

public extension ChatCoordinator {
    func toPreview(from parent: UIViewController) {
        let screen = previewFactory()
        screen.delegate = (parent as? QLPreviewControllerDelegate)
        screen.dataSource = (parent as? QLPreviewControllerDataSource)
        pushPresenter.present(screen, from: parent)
    }

    func toLibrary(from parent: UIViewController) {
        let screen = imagePickerFactory()
        screen.delegate = (parent as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
        screen.allowsEditing = false
        modalPresenter.present(screen, from: parent)
    }

    func toCamera(from parent: UIViewController) {
        let screen = imagePickerFactory()
        screen.delegate = (parent as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
        screen.sourceType = .camera
        screen.allowsEditing = false
        modalPresenter.present(screen, from: parent)
    }

    func toRetrySheet(from parent: UIViewController) {
        let screen = retryFactory()
        bottomPresenter.present(screen, from: parent)
    }

    func toContact(_ contact: Contact, from parent: UIViewController) {
        let screen = contactFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    func toWebview(with urlString: String, from parent: UIViewController) {
        let screen = webFactory(urlString)
        modalPresenter.present(screen, from: parent)
    }

    func toPermission(type: PermissionType, from parent: UIViewController) {
        let screen = permissionFactory()
        screen.setup(type: type)
        pushPresenter.present(screen, from: parent)
    }

    func toMembersList(_ screen: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(screen, from: parent)
    }

    func toDrawer(_ drawer: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(drawer, from: parent)
    }

    func toMenuSheet(_ screen: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(screen, from: parent)
    }
}
