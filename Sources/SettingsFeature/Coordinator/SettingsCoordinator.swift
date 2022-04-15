import UIKit
import Shared
import Presentation

public protocol SettingsCoordinating {
    func toBackup(from: UIViewController)
    func toDelete(from: UIViewController)
    func toAdvanced(from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toActivityController(with: [Any], from: UIViewController)
}

public struct SettingsCoordinator: SettingsCoordinating {
    public init(
        backupFactory: @escaping () -> UIViewController,
        advancedFactory: @escaping () -> UIViewController,
        accountDeleteFactory: @escaping () -> UIViewController
    ) {
        self.backupFactory = backupFactory
        self.advancedFactory = advancedFactory
        self.accountDeleteFactory = accountDeleteFactory
    }

    var pushPresenter: Presenting = PushPresenter()
    var modalPresenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var backupFactory: () -> UIViewController
    var advancedFactory: () -> UIViewController
    var accountDeleteFactory: () -> UIViewController

    var activityControllerFactory: ([Any]) -> UIViewController
        = { UIActivityViewController(activityItems: $0, applicationActivities: nil) }
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

    func toPopup(_ popup: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(popup, from: parent)
    }

    func toActivityController(with items: [Any], from parent: UIViewController) {
        let screen = activityControllerFactory(items)
        modalPresenter.present(screen, from: parent)
    }
}
