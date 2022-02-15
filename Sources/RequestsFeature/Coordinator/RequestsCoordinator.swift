import UIKit
import Shared
import Models
import Presentation
import ContactFeature

public protocol RequestsCoordinating {
    func toSearch(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toNickname(from: UIViewController, prefilled: String, _: @escaping StringClosure)
    func toVerifying(from: UIViewController)
}

public struct RequestsCoordinator: RequestsCoordinating {
    public init(searchFactory: @escaping () -> UIViewController) {
        self.searchFactory = searchFactory
    }

    // MARK: Presenters

    var pusher: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    // MARK: Factories

    var searchFactory: () -> UIViewController

    var verifyingFactory: () -> UIViewController = VerifyingController.init

    var contactFactory: (Contact) -> UIViewController
        = ContactController.init(_:)

    var nicknameFactory: (String, @escaping StringClosure) -> UIViewController
        = NickameController.init(prefilled:_:)
}

public extension RequestsCoordinator {
    func toSearch(from parent: UIViewController) {
        let screen = searchFactory()
        pusher.present(screen, from: parent)
    }

    func toContact(
        _ contact: Contact,
        from parent: UIViewController
    ) {
        let screen = contactFactory(contact)
        pusher.present(screen, from: parent)
    }

    func toNickname(
        from parent: UIViewController,
        prefilled: String,
        _ completion: @escaping StringClosure
    ) {
        let screen = nicknameFactory(prefilled, completion)
        bottomPresenter.present(screen, from: parent)
    }

    func toVerifying(from parent: UIViewController) {
        let screen = verifyingFactory()
        bottomPresenter.present(screen, from: parent)
    }
}
