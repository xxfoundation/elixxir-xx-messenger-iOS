import UIKit
import Shared
import Models
import XXModels
import MenuFeature
import ChatFeature
import Presentation

public typealias ChatListSheetClosure = (ChatListSheetController.Action) -> Void

public protocol ChatListCoordinating {
    func toScan(from: UIViewController)
    func toSearch(from: UIViewController)
    func toContacts(from: UIViewController)
    func toNewGroup(from: UIViewController)
    func toSideMenu(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toSingleChat(with: Contact, from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
    func toGroupChat(with: GroupInfo, from: UIViewController)
}

public struct ChatListCoordinator: ChatListCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var modalPresenter: Presenting = ModalPresenter()
    var sidePresenter: Presenting = SideMenuPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var scanFactory: () -> UIViewController
    var searchFactory: (String?) -> UIViewController
    var newGroupFactory: () -> UIViewController
    var contactsFactory: () -> UIViewController
    var contactFactory: (Contact) -> UIViewController
    var singleChatFactory: (Contact) -> UIViewController
    var groupChatFactory: (GroupInfo) -> UIViewController
    var sideMenuFactory: (MenuItem, UIViewController) -> UIViewController

    public init(
        scanFactory: @escaping () -> UIViewController,
        searchFactory: @escaping (String?) -> UIViewController,
        newGroupFactory: @escaping () -> UIViewController,
        contactsFactory: @escaping () -> UIViewController,
        contactFactory: @escaping (Contact) -> UIViewController,
        singleChatFactory: @escaping (Contact) -> UIViewController,
        groupChatFactory: @escaping (GroupInfo) -> UIViewController,
        sideMenuFactory: @escaping (MenuItem, UIViewController) -> UIViewController
    ) {
        self.scanFactory = scanFactory
        self.searchFactory = searchFactory
        self.contactFactory = contactFactory
        self.newGroupFactory = newGroupFactory
        self.contactsFactory = contactsFactory
        self.sideMenuFactory = sideMenuFactory
        self.groupChatFactory = groupChatFactory
        self.singleChatFactory = singleChatFactory
    }
}

public extension ChatListCoordinator {
    func toSearch(from parent: UIViewController) {
        let screen = searchFactory(nil)
        pushPresenter.present(screen, from: parent)
    }

    func toScan(from parent: UIViewController) {
        let screen = scanFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toContacts(from parent: UIViewController) {
        let screen = contactsFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toContact(_ contact: Contact, from parent: UIViewController) {
        let screen = contactFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    func toSingleChat(with contact: Contact, from parent: UIViewController) {
        let screen = singleChatFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    func toGroupChat(with group: GroupInfo, from parent: UIViewController) {
        let screen = groupChatFactory(group)
        pushPresenter.present(screen, from: parent)
    }

    func toSideMenu(from parent: UIViewController) {
        let screen = sideMenuFactory(.chats, parent)
        sidePresenter.present(screen, from: parent)
    }

    func toNewGroup(from parent: UIViewController) {
        let screen = newGroupFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toDrawer(_ drawer: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(drawer, from: parent)
    }
}
