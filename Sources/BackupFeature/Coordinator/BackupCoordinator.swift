import UIKit
import Shared
import Presentation

public protocol BackupCoordinating {
    func toDrawer(
        _: UIViewController,
        from: UIViewController
    )

    func toSFTP(from: UIViewController)

    func toPassphrase(
        from: UIViewController,
        cancelClosure: @escaping EmptyClosure,
        passphraseClosure: @escaping StringClosure
    )
}

public struct BackupCoordinator: BackupCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var sftpFactory: () -> UIViewController
    var passphraseFactory: (@escaping EmptyClosure, @escaping StringClosure) -> UIViewController

    public init(
        sftpFactory: @escaping () -> UIViewController,
        passphraseFactory: @escaping (@escaping EmptyClosure, @escaping StringClosure) -> UIViewController
    ) {
        self.sftpFactory = sftpFactory
        self.passphraseFactory = passphraseFactory
    }
}

public extension BackupCoordinator {
    func toSFTP(from parent: UIViewController) {
        let screen = sftpFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toDrawer(
        _ screen: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(screen, from: parent)
    }

    func toPassphrase(
        from parent: UIViewController,
        cancelClosure: @escaping EmptyClosure,
        passphraseClosure: @escaping StringClosure
    ) {
        let screen = passphraseFactory(cancelClosure, passphraseClosure)
        bottomPresenter.present(screen, from: parent)
    }
}
