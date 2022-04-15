import UIKit
import Shared
import Models
import ChatFeature
import Presentation
import ContactFeature
import ScrollViewController

public protocol ContactListCoordinating {
    func toScan(from: UIViewController)
    func toSearch(from: UIViewController)
    func toRequests(from: UIViewController)
    func toNewGroup(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toGroupChat(with: GroupChatInfo, from: UIViewController)
    func toGroupPopup(with: Int, from: UIViewController, _: @escaping (String, String?) -> Void)
}

public struct ContactListCoordinator: ContactListCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var fullscreenPresenter: Presenting = FullscreenPresenter()
    var replacePresenter: Presenting = ReplacePresenter(mode: .replaceLast)

    var scanFactory: () -> UIViewController
    var searchFactory: () -> UIViewController
    var newGroupFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController
    var contactFactory: (Contact) -> UIViewController
    var groupChatFactory: (GroupChatInfo) -> UIViewController
    var groupPopupFactory: (Int, @escaping (String, String?) -> Void) -> UIViewController

    public init(
        scanFactory: @escaping () -> UIViewController,
        searchFactory: @escaping () -> UIViewController,
        newGroupFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController,
        contactFactory: @escaping (Contact) -> UIViewController,
        groupChatFactory: @escaping (GroupChatInfo) -> UIViewController,
        groupPopupFactory: @escaping (Int, @escaping (String, String?) -> Void) -> UIViewController
    ) {
        self.scanFactory = scanFactory
        self.searchFactory = searchFactory
        self.newGroupFactory = newGroupFactory
        self.requestsFactory = requestsFactory
        self.contactFactory = contactFactory
        self.groupChatFactory = groupChatFactory
        self.groupPopupFactory = groupPopupFactory
    }
}

public extension ContactListCoordinator {
    func toGroupPopup(
        with count: Int,
        from parent: UIViewController,
        _ completion: @escaping (String, String?) -> Void
    ) {
        let screen =  ScrollViewController.embedding(groupPopupFactory(count, completion))
        fullscreenPresenter.present(screen, from: parent)
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
        replacePresenter.present(screen, from: parent)
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
