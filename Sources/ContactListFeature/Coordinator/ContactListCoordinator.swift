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

    func toGroupChat(
        with: GroupChatInfo,
        from: UIViewController
    )

    func toGroupPopup(
        with: Int,
        from: UIViewController,
        _: @escaping (String, String?) -> Void
    )
}

public struct ContactListCoordinator: ContactListCoordinating {
    public init(
        scanFactory: @escaping () -> UIViewController,
        searchFactory: @escaping () -> UIViewController,
        newGroupFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController
    ) {
        self.scanFactory = scanFactory
        self.searchFactory = searchFactory
        self.newGroupFactory = newGroupFactory
        self.requestsFactory = requestsFactory
    }

    // MARK: Presenters

    var pusher: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var fullscreenPresenter: Presenting = FullscreenPresenter()
    var replacer: Presenting = ReplacePresenter(mode: .replaceLast)

    // MARK: Factories

    var scanFactory: () -> UIViewController
    var searchFactory: () -> UIViewController
    var newGroupFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController

    var contactFactory: (Contact) -> UIViewController
    = ContactController.init(_:)

    var groupChatFactory: (GroupChatInfo) -> UIViewController
    = GroupChatController.init(_:)

    var groupPopupFactory: (Int, @escaping (String, String?) -> Void) -> UIViewController
    = CreatePopupController.init(_:_:)
}

public extension ContactListCoordinator {
    func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        pusher.present(screen, from: parent)
    }

    func toScan(from parent: UIViewController) {
        let screen = scanFactory()
        pusher.present(screen, from: parent)
    }

    func toSearch(from parent: UIViewController) {
        let screen = searchFactory()
        pusher.present(screen, from: parent)
    }

    func toContact(_ contact: Contact, from parent: UIViewController) {
        let screen = contactFactory(contact)
        pusher.present(screen, from: parent)
    }

    func toNewGroup(from parent: UIViewController) {
        let screen = newGroupFactory()
        pusher.present(screen, from: parent)
    }

    func toGroupChat(
        with info: GroupChatInfo,
        from parent: UIViewController
    ) {
        let screen = groupChatFactory(info)
        replacer.present(screen, from: parent)
    }

    func toGroupPopup(
        with count: Int,
        from parent: UIViewController,
        _ completion: @escaping (String, String?) -> Void
    ) {
        let screen =  ScrollViewController.embedding(groupPopupFactory(count, completion))
        fullscreenPresenter.present(screen, from: parent)
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
