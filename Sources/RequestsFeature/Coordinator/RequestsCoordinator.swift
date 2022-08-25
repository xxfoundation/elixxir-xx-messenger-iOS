import UIKit
import Shared
import Models
import XXModels
import MenuFeature
import Presentation
import ContactFeature
import ScrollViewController

public protocol RequestsCoordinating {
    func toSearch(from: UIViewController)
    func toSideMenu(from: UIViewController)
    func toContact(_: Contact, from: UIViewController)
    func toSingleChat(with: Contact, from: UIViewController)
    func toGroupChat(with: GroupInfo, from: UIViewController)
    func toDrawer(_:  UIViewController, from: UIViewController)
    func toDrawerBottom(_:  UIViewController, from: UIViewController)
    func toNickname(from: UIViewController, prefilled: String, _: @escaping StringClosure)
}

public struct RequestsCoordinator: RequestsCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var sidePresenter: Presenting = SideMenuPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var fullscreenPresenter: Presenting = FullscreenPresenter()

    var searchFactory: (String?) -> UIViewController
    var contactFactory: (Contact) -> UIViewController
    var singleChatFactory: (Contact) -> UIViewController
    var groupChatFactory: (GroupInfo) -> UIViewController
    var sideMenuFactory: (MenuItem, UIViewController) -> UIViewController
    var nicknameFactory: (String, @escaping StringClosure) -> UIViewController

    public init(
        searchFactory: @escaping (String?) -> UIViewController,
        contactFactory: @escaping (Contact) -> UIViewController,
        singleChatFactory: @escaping (Contact) -> UIViewController,
        groupChatFactory: @escaping (GroupInfo) -> UIViewController,
        sideMenuFactory: @escaping (MenuItem, UIViewController) -> UIViewController,
        nicknameFactory: @escaping (String, @escaping StringClosure) -> UIViewController
    ) {
        self.searchFactory = searchFactory
        self.contactFactory = contactFactory
        self.nicknameFactory = nicknameFactory
        self.sideMenuFactory = sideMenuFactory
        self.groupChatFactory = groupChatFactory
        self.singleChatFactory = singleChatFactory
    }
}

public extension RequestsCoordinator {
    func toSingleChat(
        with contact: Contact,
        from parent: UIViewController
    ) {
        let screen = singleChatFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    func toGroupChat(
        with info: GroupInfo,
        from parent: UIViewController
    ) {
        let screen = groupChatFactory(info)
        pushPresenter.present(screen, from: parent)
    }

    func toDrawer(
        _ drawer: UIViewController,
        from parent: UIViewController
    ) {
        let target = ScrollViewController.embedding(drawer)
        fullscreenPresenter.present(target, from: parent)
    }

    func toDrawerBottom(
        _ drawer: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(drawer, from: parent)
    }

    func toSearch(from parent: UIViewController) {
        let screen = searchFactory(nil)
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

    func toContact(_ contact: Contact, from parent: UIViewController) {
        let screen = contactFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    func toSideMenu(from parent: UIViewController) {
        let screen = sideMenuFactory(.requests, parent)
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
