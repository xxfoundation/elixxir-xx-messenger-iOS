import UIKit
import Models
import MenuFeature
import Presentation
import ContactFeature

public protocol ScanCoordinating {
    func toContacts(from: UIViewController)
    func toRequests(from: UIViewController)
    func toSideMenu(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
}

public struct ScanCoordinator: ScanCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var sidePresenter: Presenting = SideMenuPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacePresenter: Presenting = ReplacePresenter(mode: .replaceLast)

    var contactsFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController
    var contactFactory: (Contact) -> UIViewController
    var sideMenuFactory: (MenuItem, UIViewController) -> UIViewController

    public init(
        contactsFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController,
        contactFactory: @escaping (Contact) -> UIViewController,
        sideMenuFactory: @escaping (MenuItem, UIViewController) -> UIViewController
    ) {
        self.contactFactory = contactFactory
        self.contactsFactory = contactsFactory
        self.requestsFactory = requestsFactory
        self.sideMenuFactory = sideMenuFactory
    }
}

public extension ScanCoordinator {
    func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toContacts(from parent: UIViewController) {
        let screen = contactsFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toContact(_ contact: Contact, from parent: UIViewController) {
        let screen = contactFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    public func toDrawer(_ drawer: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(drawer, from: parent)
    }

    func toSideMenu(from parent: UIViewController) {
        let screen = sideMenuFactory(.scan, parent)
        sidePresenter.present(screen, from: parent)
    }
}
