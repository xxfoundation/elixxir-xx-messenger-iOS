import UIKit
import Shared
import Models
import MenuFeature
import ChatFeature
import Presentation

public typealias ChatListSheetClosure = (ChatListSheetController.Action) -> Void

public protocol ChatListCoordinating {
    func toScan(from: UIViewController)
    func toSearch(from: UIViewController)
    func toProfile(from: UIViewController)
    func toSettings(from: UIViewController)
    func toContacts(from: UIViewController)
    func toRequests(from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toSideMenu<T: UIViewController>(from: T) where T: MenuDelegate

    func toSingleChat(with: Contact, from: UIViewController)

    func toGroupChat(
        with: GroupChatInfo,
        from: UIViewController
    )
}

public struct ChatListCoordinator: ChatListCoordinating {
    public init(
        scanFactory: @escaping () -> UIViewController,
        searchFactory: @escaping () -> UIViewController,
        profileFactory: @escaping () -> UIViewController,
        settingsFactory: @escaping () -> UIViewController,
        contactsFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController
    ) {
        self.scanFactory = scanFactory
        self.searchFactory = searchFactory
        self.profileFactory = profileFactory
        self.settingsFactory = settingsFactory
        self.contactsFactory = contactsFactory
        self.requestsFactory = requestsFactory
    }

    // MARK: Presenters

    var pusher: Presenting = PushPresenter()
    var sider: Presenting = SideMenuPresenter()
    var presenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    // MARK: Factories

    var scanFactory: () -> UIViewController
    var searchFactory: () -> UIViewController
    var profileFactory: () -> UIViewController
    var settingsFactory: () -> UIViewController
    var contactsFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController

    var groupChatFactory: (GroupChatInfo) -> UIViewController
    = GroupChatController.init(_:)

    var singleChatFactory: (Contact) -> UIViewController
    = SingleChatController.init(_:)

    var sideMenuFactory: (MenuDelegate) -> UIViewController
    = MenuController.init(_:)
}

public extension ChatListCoordinator {
    func toSingleChat(
        with contact: Contact,
        from parent: UIViewController
    ) {
        let screen = singleChatFactory(contact)
        pusher.present(screen, from: parent)
    }

    func toGroupChat(
        with group: GroupChatInfo,
        from parent: UIViewController
    ) {
        let screen = groupChatFactory(group)
        pusher.present(screen, from: parent)
    }

    func toSideMenu<T: UIViewController>(from parent: T) where T: MenuDelegate {
        let screen = sideMenuFactory(parent)
        sider.present(screen, from: parent)
    }

    func toPopup(
        _ popup: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(popup, from: parent)
    }

    func toSearch(from parent: UIViewController) {
        let screen = searchFactory()
        pusher.present(screen, from: parent)
    }

    func toScan(from parent: UIViewController) {
        let screen = scanFactory()
        pusher.present(screen, from: parent)
    }

    func toProfile(from parent: UIViewController) {
        let screen = profileFactory()
        pusher.present(screen, from: parent)
    }

    func toContacts(from parent: UIViewController) {
        let screen = contactsFactory()
        pusher.present(screen, from: parent)
    }

    func toSettings(from parent: UIViewController) {
        let screen = settingsFactory()
        pusher.present(screen, from: parent)
    }

    func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        pusher.present(screen, from: parent)
    }
}
