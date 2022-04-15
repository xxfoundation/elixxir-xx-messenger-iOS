import UIKit
import Models
import Shared
import ChatFeature
import Presentation

public protocol ContactCoordinating: AnyObject {
    func toPhotos(from: UIViewController)
    func toRequests(from: UIViewController)
    func toSingleChat(with: Contact, from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toNickname(from: UIViewController, prefilled: String, _: @escaping StringClosure)
}

public final class ContactCoordinator: ContactCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var modalPresenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacePresenter: Presenting = ReplacePresenter(mode: .replaceBackwards(SingleChatController.self))

    var requestsFactory: () -> UIViewController
    var singleChatFactory: (Contact) -> UIViewController
    var imagePickerFactory: () -> UIImagePickerController
    var nicknameFactory: (String, @escaping StringClosure) -> UIViewController

    public init(
        requestsFactory: @escaping () -> UIViewController,
        singleChatFactory: @escaping (Contact) -> UIViewController,
        imagePickerFactory: @escaping () -> UIImagePickerController,
        nicknameFactory: @escaping (String, @escaping StringClosure) -> UIViewController
    ) {
        self.requestsFactory = requestsFactory
        self.singleChatFactory = singleChatFactory
        self.imagePickerFactory = imagePickerFactory
        self.nicknameFactory = nicknameFactory
    }
}

public extension ContactCoordinator {
    func toPhotos(from parent: UIViewController) {
        let screen = imagePickerFactory()
        screen.delegate = (parent as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
        screen.allowsEditing = true
        modalPresenter.present(screen, from: parent)
    }

    func toNickname(
        from parent: UIViewController,
        prefilled: String,
        _ completion: @escaping StringClosure
    ) {
        let screen = nicknameFactory(prefilled, completion)
        bottomPresenter.present(screen, from: parent)
    }

    func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toPopup(_ popup: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(popup, from: parent)
    }

    func toSingleChat(with contact: Contact, from parent: UIViewController) {
        let screen = singleChatFactory(contact)
        replacePresenter.present(screen, from: parent)
    }
}
