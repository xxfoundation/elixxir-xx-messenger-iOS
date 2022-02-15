import UIKit
import Presentation

public final class PresenterDouble: Presenting {
    public var didPresentFrom: UIViewController?
    public var didPresentTarget: UIViewController?

    public init() {}

    public func present(
        _ target: UIViewController,
        from parent: UIViewController
    ) {
        didPresentFrom = parent
        didPresentTarget = target
    }
}
