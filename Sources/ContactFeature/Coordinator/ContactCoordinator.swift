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
    public init(requestsFactory: @escaping () -> UIViewController) {
        self.requestsFactory = requestsFactory
    }

    // MARK: Presenters

    var pusher: Presenting = PushPresenter()
    var presenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacer: Presenting = ReplacePresenter(mode: .replaceBackwards(SingleChatController.self))

    // MARK: Factories

    var requestsFactory: () -> UIViewController

    var singleChatFactory: (Contact) -> UIViewController
    = SingleChatController.init(_:)

    var imagePickerFactory: () -> UIImagePickerController
    = UIImagePickerController.init

    var nicknameFactory: (String, @escaping StringClosure) -> UIViewController
    = NickameController.init(prefilled:_:)
}

public extension ContactCoordinator {
    func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        pusher.present(screen, from: parent)
    }

    func toPopup(
        _ popup: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(popup, from: parent)
    }

    func toSingleChat(
        with contact: Contact,
        from parent: UIViewController
    ) {
        let screen = singleChatFactory(contact)
        replacer.present(screen, from: parent)
    }

    func toPhotos(from parent: UIViewController) {
        let screen = imagePickerFactory()
        screen.delegate = (parent as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
        screen.allowsEditing = true
        presenter.present(screen, from: parent)
    }

    func toNickname(
        from parent: UIViewController,
        prefilled: String,
        _ completion: @escaping StringClosure
    ) {
        let screen = nicknameFactory(prefilled, completion)
        bottomPresenter.present(screen, from: parent)
    }
}
