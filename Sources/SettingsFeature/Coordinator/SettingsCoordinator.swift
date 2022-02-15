import UIKit
import Shared
import Presentation

public protocol SettingsCoordinating {
    func toAdvanced(from: UIViewController)
    func toAccountDelete(from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toActivityController(with: [Any], from: UIViewController)
}

public struct SettingsCoordinator: SettingsCoordinating {
    public init() {}

    // MARK: Presenters

    var pusher: Presenting = PushPresenter()
    var presenter: Presenting = ModalPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    // MARK: Factories

    var advancedFactory: () -> UIViewController = AdvancedController.init

    var accountDeleteFactory: () -> UIViewController = AccountDeleteController.init

    var activityControllerFactory: ([Any]) -> UIViewController
        = { UIActivityViewController(activityItems: $0, applicationActivities: nil) }
}

public extension SettingsCoordinator {
    func toPopup(
        _ popup: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(popup, from: parent)
    }

    func toAdvanced(from parent: UIViewController) {
        let screen = advancedFactory()
        pusher.present(screen, from: parent)
    }

    func toActivityController(
        with items: [Any],
        from parent: UIViewController
    ) {
        let screen = activityControllerFactory(items)
        presenter.present(screen, from: parent)
    }

    func toAccountDelete(from parent: UIViewController) {
        let screen = accountDeleteFactory()
        pusher.present(screen, from: parent)
    }
}
