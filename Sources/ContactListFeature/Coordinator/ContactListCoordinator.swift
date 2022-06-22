import UIKit
import Shared
import Models
import XXModels
import MenuFeature
import ChatFeature
import Presentation
import ContactFeature
import ScrollViewController

public protocol ContactListCoordinating {
    func toScan(from: UIViewController)
    func toSearch(from: UIViewController)
    func toRequests(from: UIViewController)
    func toNewGroup(from: UIViewController)
    func toSideMenu(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toSingleChat(with: Contact, from: UIViewController)
    func toGroupChat(with: GroupChatInfo, from: UIViewController)
    func toGroupDrawer(with: Int, from: UIViewController, _: @escaping (String, String?) -> Void)
}

public struct ContactListCoordinator: ContactListCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var sidePresenter: Presenting = SideMenuPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var fullscreenPresenter: Presenting = FullscreenPresenter()

    var scanFactory: () -> UIViewController
    var searchFactory: () -> UIViewController
    var newGroupFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController
    var contactFactory: (Contact) -> UIViewController
    var singleChatFactory: (Contact) -> UIViewController
    var groupChatFactory: (GroupChatInfo) -> UIViewController
    var sideMenuFactory: (MenuItem, UIViewController) -> UIViewController
    var groupDrawerFactory: (Int, @escaping (String, String?) -> Void) -> UIViewController

    public init(
        scanFactory: @escaping () -> UIViewController,
        searchFactory: @escaping () -> UIViewController,
        newGroupFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController,
        contactFactory: @escaping (Contact) -> UIViewController,
        singleChatFactory: @escaping (Contact) -> UIViewController,
        groupChatFactory: @escaping (GroupChatInfo) -> UIViewController,
        sideMenuFactory: @escaping (MenuItem, UIViewController) -> UIViewController,
        groupDrawerFactory: @escaping (Int, @escaping (String, String?) -> Void) -> UIViewController
    ) {
        self.scanFactory = scanFactory
        self.searchFactory = searchFactory
        self.contactFactory = contactFactory
        self.newGroupFactory = newGroupFactory
        self.requestsFactory = requestsFactory
        self.sideMenuFactory = sideMenuFactory
        self.groupChatFactory = groupChatFactory
        self.singleChatFactory = singleChatFactory
        self.groupDrawerFactory = groupDrawerFactory
    }
}

public extension ContactListCoordinator {
    func toGroupDrawer(
        with count: Int,
        from parent: UIViewController,
        _ completion: @escaping (String, String?) -> Void
    ) {
        let screen = ScrollViewController.embedding(groupDrawerFactory(count, completion))
        fullscreenPresenter.present(screen, from: parent)
    }

    func toSingleChat(
        with contact: Contact,
        from parent: UIViewController
    ) {
        let screen = singleChatFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    func toScan(from parent: UIViewController) {
        let screen = scanFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toSearch(from parent: UIViewController) {
        let screen = searchFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toNewGroup(from parent: UIViewController) {
        let screen = newGroupFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toContact(_ contact: Contact, from parent: UIViewController) {
        let screen = contactFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    func toGroupChat(with info: GroupChatInfo, from parent: UIViewController) {
        let screen = groupChatFactory(info)
        pushPresenter.present(screen, from: parent)
    }

    func toSideMenu(from parent: UIViewController) {
        let screen = sideMenuFactory(.contacts, parent)
        sidePresenter.present(screen, from: parent)
    }
}

extension ScrollViewController {
    static func embedding(_ viewController: UIViewController) -> ScrollViewController {
        let scrollViewController = ScrollViewController()
        scrollViewController.addChild(viewController)
        scrollViewController.contentView = viewController.view
        scrollViewController.wrapperView.handlesTouchesOutsideContent = false
        scrollViewController.wrapperView.alignContentToBottom = true
        scrollViewController.scrollView.bounces = false

        viewController.didMove(toParent: scrollViewController)
        return scrollViewController
    }
}
