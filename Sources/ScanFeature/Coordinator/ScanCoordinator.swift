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
    public init(
        contactsFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController
    ) {
        self.contactsFactory = contactsFactory
        self.requestsFactory = requestsFactory
    }

    // MARK: Presenters

    var pusher: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacer: Presenting = ReplacePresenter(mode: .replaceLast)

    // MARK: Factories

    var contactsFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController

    var contactFactory: (Contact) -> UIViewController
        = ContactController.init(_:)
}

extension ScanCoordinator: ScanCoordinating {
    public func toPopup(
        _ popup: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(popup, from: parent)
    }

    public func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        replacer.present(screen, from: parent)
    }

    public func toContacts(from parent: UIViewController) {
        let screen = contactsFactory()
        replacer.present(screen, from: parent)
    }

    public func toContact(
        _ contact: Contact,
        from parent: UIViewController
    ) {
        let screen = contactFactory(contact)
        pusher.present(screen, from: parent)
    }
}
