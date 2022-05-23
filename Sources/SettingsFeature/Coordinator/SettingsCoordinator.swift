import UIKit
import Shared
import MenuFeature
import Presentation

public protocol SettingsCoordinating {
    func toBackup(from: UIViewController)
    func toDelete(from: UIViewController)
    func toAdvanced(from: UIViewController)
    func toSideMenu(from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
    func toActivityController(with: [Any], from: UIViewController)
}

public struct SettingsCoordinator: SettingsCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var modalPresenter: Presenting = ModalPresenter()
    var sidePresenter: Presenting = SideMenuPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var backupFactory: () -> UIViewController
    var advancedFactory: () -> UIViewController
    var accountDeleteFactory: () -> UIViewController
    var sideMenuFactory: (MenuItem, UIViewController) -> UIViewController
    var activityControllerFactory: ([Any]) -> UIViewController
    = { UIActivityViewController(activityItems: $0, applicationActivities: nil) }

    public init(
        backupFactory: @escaping () -> UIViewController,
        advancedFactory: @escaping () -> UIViewController,
        accountDeleteFactory: @escaping () -> UIViewController,
        sideMenuFactory: @escaping (MenuItem, UIViewController) -> UIViewController
    ) {
        self.backupFactory = backupFactory
        self.advancedFactory = advancedFactory
        self.sideMenuFactory = sideMenuFactory
        self.accountDeleteFactory = accountDeleteFactory
    }
}

public extension SettingsCoordinator {
    func toAdvanced(from parent: UIViewController) {
        let screen = advancedFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toDelete(from parent: UIViewController) {
        let screen = accountDeleteFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toBackup(from parent: UIViewController) {
        let screen = backupFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toDrawer(_ drawer: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(drawer, from: parent)
    }

    func toActivityController(with items: [Any], from parent: UIViewController) {
        let screen = activityControllerFactory(items)
        modalPresenter.present(screen, from: parent)
    }

    func toSideMenu(from parent: UIViewController) {
        let screen = sideMenuFactory(.settings, parent)
        sidePresenter.present(screen, from: parent)
    }
}
