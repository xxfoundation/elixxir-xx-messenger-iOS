import UIKit
import Models
import Shared
import Presentation

public protocol RestoreCoordinating {
    func toChats(from: UIViewController)
    func toSuccess(from: UIViewController)
    func toSFTP(using: String, from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
    func toPassphrase(from: UIViewController, _: @escaping StringClosure)
    func toRestore(using: String, with: RestoreSettings, from: UIViewController)
    func toRestoreReplacing(using: String, with: RestoreSettings, from: UIViewController)
}

public struct RestoreCoordinator: RestoreCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacePresenter: Presenting = ReplacePresenter()
    var replaceLastPresenter: Presenting = ReplacePresenter(mode: .replaceLast)

    var successFactory: () -> UIViewController
    var chatListFactory: () -> UIViewController
    var sftpFactory: (String) -> UIViewController
    var restoreFactory: (String, RestoreSettings) -> UIViewController
    var passphraseFactory: (@escaping StringClosure) -> UIViewController

    public init(
        successFactory: @escaping () -> UIViewController,
        chatListFactory: @escaping () -> UIViewController,
        sftpFactory: @escaping (String) -> UIViewController,
        restoreFactory: @escaping (String, RestoreSettings) -> UIViewController,
        passphraseFactory: @escaping (@escaping StringClosure) -> UIViewController
    ) {
        self.sftpFactory = sftpFactory
        self.successFactory = successFactory
        self.restoreFactory = restoreFactory
        self.chatListFactory = chatListFactory
        self.passphraseFactory = passphraseFactory
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

    func toRestoreReplacing(
        using ndf: String,
        with settings: RestoreSettings,
        from parent: UIViewController
    ) {
        let screen = restoreFactory(ndf, settings)
        replaceLastPresenter.present(screen, from: parent)
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

    func toSFTP(using ndf: String, from parent: UIViewController) {
        let screen = sftpFactory(ndf)
        pushPresenter.present(screen, from: parent)
    }
}
