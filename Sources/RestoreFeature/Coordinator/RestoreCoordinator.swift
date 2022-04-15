import UIKit
import Models
import Presentation

public protocol RestoreCoordinating {
    func toChats(from: UIViewController)
    func toSuccess(from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toRestore(using: String, with: RestoreSettings, from: UIViewController)
}

public struct RestoreCoordinator: RestoreCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacePresenter: Presenting = ReplacePresenter()

    var successFactory: () -> UIViewController
    var chatListFactory: () -> UIViewController
    var restoreFactory: (String, RestoreSettings) -> UIViewController

    public init(
        successFactory: @escaping () -> UIViewController,
        chatListFactory: @escaping () -> UIViewController,
        restoreFactory: @escaping (String, RestoreSettings) -> UIViewController
    ) {
        self.successFactory = successFactory
        self.restoreFactory = restoreFactory
        self.chatListFactory = chatListFactory
    }
}

public extension RestoreCoordinator {
    func toRestore(
        using ndf: String,
        with settings: RestoreSettings,
        from parent: UIViewController
    ) {
        let screen = restoreFactory(ndf, settings)
        pushPresenter.present(screen, from: parent)
    }

    func toChats(from parent: UIViewController) {
        let screen = chatListFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toSuccess(from parent: UIViewController) {
        let screen = successFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toPopup(_ popup: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(popup, from: parent)
    }
}
