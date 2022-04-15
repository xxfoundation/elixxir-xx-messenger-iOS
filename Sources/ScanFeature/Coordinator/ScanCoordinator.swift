import UIKit
import Models
import Presentation
import ContactFeature

public protocol ScanCoordinating {
    func toContacts(from: UIViewController)
    func toRequests(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
}

public struct ScanCoordinator {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacePresenter: Presenting = ReplacePresenter(mode: .replaceLast)

    var contactsFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController
    var contactFactory: (Contact) -> UIViewController

    public init(
        contactsFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController,
        contactFactory: @escaping (Contact) -> UIViewController
    ) {
        self.contactFactory = contactFactory
        self.contactsFactory = contactsFactory
        self.requestsFactory = requestsFactory
    }
}

extension ScanCoordinator: ScanCoordinating {
    public func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        replacePresenter.present(screen, from: parent)
    }

    public func toContacts(from parent: UIViewController) {
        let screen = contactsFactory()
        replacePresenter.present(screen, from: parent)
    }

    public func toContact(_ contact: Contact, from parent: UIViewController) {
        let screen = contactFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    public func toPopup(_ popup: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(popup, from: parent)
    }
}
