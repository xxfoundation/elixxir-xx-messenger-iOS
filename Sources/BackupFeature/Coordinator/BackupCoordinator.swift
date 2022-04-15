import UIKit
import Presentation

public protocol BackupCoordinating {
    func toPopup(_: UIViewController, from: UIViewController)
}

public struct BackupCoordinator: BackupCoordinating {
    var bottomPresenter: Presenting = BottomPresenter()

    public init() {}
}

public extension BackupCoordinator {
    func toPopup(_ screen: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(screen, from: parent)
    }
}
