import UIKit
import Shared
import Presentation

public protocol BackupCoordinating {
    func toPopup(
        _: UIViewController,
        from: UIViewController
    )

    func toPassphrase(
        from: UIViewController,
        cancelClosure: @escaping EmptyClosure,
        passphraseClosure: @escaping StringClosure
    )
}

public struct BackupCoordinator: BackupCoordinating {
    var bottomPresenter: Presenting = BottomPresenter()

    var passphraseFactory: (
        @escaping EmptyClosure,
        @escaping StringClosure
    ) -> UIViewController

    public init(
        passphraseFactory: @escaping (
            @escaping EmptyClosure,
            @escaping StringClosure
        ) -> UIViewController
    ) {
        self.passphraseFactory = passphraseFactory
    }
}

public extension BackupCoordinator {
    func toPopup(
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
