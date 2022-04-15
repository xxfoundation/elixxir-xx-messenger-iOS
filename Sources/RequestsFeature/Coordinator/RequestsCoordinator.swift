import UIKit
import Shared
import Models
import Presentation
import ContactFeature

public protocol RequestsCoordinating {
    func toSearch(from: UIViewController)
    func toVerifying(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toNickname(from: UIViewController, prefilled: String, _: @escaping StringClosure)
}

public struct RequestsCoordinator: RequestsCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var searchFactory: () -> UIViewController
    var verifyingFactory: () -> UIViewController
    var contactFactory: (Contact) -> UIViewController
    var nicknameFactory: (String, @escaping StringClosure) -> UIViewController

    public init(
        searchFactory: @escaping () -> UIViewController,
        verifyingFactory: @escaping () -> UIViewController,
        contactFactory: @escaping (Contact) -> UIViewController,
        nicknameFactory: @escaping (String, @escaping StringClosure) -> UIViewController
    ) {
        self.searchFactory = searchFactory
        self.contactFactory = contactFactory
        self.nicknameFactory = nicknameFactory
        self.verifyingFactory = verifyingFactory
    }
}

public extension RequestsCoordinator {
    func toSearch(from parent: UIViewController) {
        let screen = searchFactory()
        pushPresenter.present(screen, from: parent)
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

    func toContact(_ contact: Contact, from parent: UIViewController) {
        let screen = contactFactory(contact)
        pushPresenter.present(screen, from: parent)
    }
}
