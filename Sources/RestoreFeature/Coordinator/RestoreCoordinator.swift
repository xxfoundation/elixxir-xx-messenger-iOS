import UIKit
import Models
import Shared
import Presentation

public protocol RestoreCoordinating {
    func toChats(from: UIViewController)
    func toSuccess(from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
    func toPassphrase(from: UIViewController, _: @escaping StringClosure)
    func toRestore(with: RestoreSettings, from: UIViewController)
}

public struct RestoreCoordinator: RestoreCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacePresenter: Presenting = ReplacePresenter()

    var successFactory: () -> UIViewController
    var chatListFactory: () -> UIViewController
    var restoreFactory: (RestoreSettings) -> UIViewController
    var passphraseFactory: (@escaping StringClosure) -> UIViewController

    public init(
        successFactory: @escaping () -> UIViewController,
        chatListFactory: @escaping () -> UIViewController,
        restoreFactory: @escaping (RestoreSettings) -> UIViewController,
        passphraseFactory: @escaping (@escaping StringClosure) -> UIViewController
    ) {
        self.successFactory = successFactory
        self.restoreFactory = restoreFactory
        self.chatListFactory = chatListFactory
        self.passphraseFactory = passphraseFactory
    }
}

public extension RestoreCoordinator {
    func toRestore(
        with settings: RestoreSettings,
        from parent: UIViewController
    ) {
        let screen = restoreFactory(settings)
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

    func toDrawer(_ drawer: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(drawer, from: parent)
    }

    func toPassphrase(
        from parent: UIViewController,
        _ completion: @escaping StringClosure
    ) {
        let screen = passphraseFactory(completion)
        bottomPresenter.present(screen, from: parent)
    }
}
