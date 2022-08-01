import UIKit
import Presentation

public protocol MenuCoordinating {
    func toFlow(_ item: MenuItem, from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
    func toActivityController(with: [Any], from: UIViewController)
}

public struct MenuCoordinator: MenuCoordinating {
    var modalPresenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacePresenter: Presenting = ReplacePresenter()

    var scanFactory: () -> UIViewController
    var chatsFactory: () -> UIViewController
    var profileFactory: () -> UIViewController
    var settingsFactory: () -> UIViewController
    var contactsFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController
    var activityControllerFactory: ([Any]) -> UIViewController
    = { UIActivityViewController(activityItems: $0, applicationActivities: nil) }

    public init(
        scanFactory: @escaping () -> UIViewController,
        chatsFactory: @escaping () -> UIViewController,
        profileFactory: @escaping () -> UIViewController,
        settingsFactory: @escaping () -> UIViewController,
        contactsFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController
    ) {
        self.scanFactory = scanFactory
        self.chatsFactory = chatsFactory
        self.profileFactory = profileFactory
        self.settingsFactory = settingsFactory
        self.contactsFactory = contactsFactory
        self.requestsFactory = requestsFactory
    }
}

public extension MenuCoordinator {
    func toDrawer(_ drawer: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(drawer, from: parent)
    }

    func toFlow(_ item: MenuItem, from parent: UIViewController) {
        let controller: UIViewController

        switch item {
        case .scan:
            controller = scanFactory()
        case .chats:
            controller = chatsFactory()
        case .profile:
            controller = profileFactory()
        case .contacts:
            controller = contactsFactory()
        case .requests:
            controller = requestsFactory()
        case .settings:
            controller = settingsFactory()
        default:
            fatalError()
        }

        replacePresenter.present(controller, from: parent)
    }

    func toActivityController(with items: [Any], from parent: UIViewController) {
        let screen = activityControllerFactory(items)
        modalPresenter.present(screen, from: parent)
    }
}
