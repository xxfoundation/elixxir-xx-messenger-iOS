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
    func toSingleChat(with: Contact, from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toGroupChat(with: GroupChatInfo, from: UIViewController)
    func toSideMenu<T: UIViewController>(from: T) where T: MenuDelegate
}

public struct ChatListCoordinator: ChatListCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var modalPresenter: Presenting = ModalPresenter()
    var sidePresenter: Presenting = SideMenuPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var scanFactory: () -> UIViewController
    var searchFactory: () -> UIViewController
    var profileFactory: () -> UIViewController
    var settingsFactory: () -> UIViewController
    var contactsFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController
    var singleChatFactory: (Contact) -> UIViewController
    var sideMenuFactory: (MenuDelegate) -> UIViewController
    var groupChatFactory: (GroupChatInfo) -> UIViewController

    public init(
        scanFactory: @escaping () -> UIViewController,
        searchFactory: @escaping () -> UIViewController,
        profileFactory: @escaping () -> UIViewController,
        settingsFactory: @escaping () -> UIViewController,
        contactsFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController,
        singleChatFactory: @escaping (Contact) -> UIViewController,
        sideMenuFactory: @escaping (MenuDelegate) -> UIViewController,
        groupChatFactory: @escaping (GroupChatInfo) -> UIViewController
    ) {
        self.scanFactory = scanFactory
        self.searchFactory = searchFactory
        self.profileFactory = profileFactory
        self.settingsFactory = settingsFactory
        self.contactsFactory = contactsFactory
        self.requestsFactory = requestsFactory
        self.sideMenuFactory = sideMenuFactory
        self.groupChatFactory = groupChatFactory
        self.singleChatFactory = singleChatFactory
    }
}

public extension ChatListCoordinator {
    func toSearch(from parent: UIViewController) {
        let screen = searchFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toScan(from parent: UIViewController) {
        let screen = scanFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toProfile(from parent: UIViewController) {
        let screen = profileFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toContacts(from parent: UIViewController) {
        let screen = contactsFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toSettings(from parent: UIViewController) {
        let screen = settingsFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toSingleChat(with contact: Contact, from parent: UIViewController) {
        let screen = singleChatFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    func toGroupChat(with group: GroupChatInfo, from parent: UIViewController) {
        let screen = groupChatFactory(group)
        pushPresenter.present(screen, from: parent)
    }

    func toSideMenu<T: UIViewController>(from parent: T) where T: MenuDelegate {
        let screen = sideMenuFactory(parent)
        sidePresenter.present(screen, from: parent)
    }

    func toPopup(_ popup: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(popup, from: parent)
    }
}
