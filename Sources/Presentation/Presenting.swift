import UIKit
import Theme

public protocol Presenting {
    func present(_ target: UIViewController..., from parent: UIViewController)
    func dismiss(from parent: UIViewController)
}

public extension Presenting {
    func dismiss(from parent: UIViewController) {
        parent.dismiss(animated: true)
    }
}

public struct PushPresenter: Presenting {
    public init() {}

    public func present(_ target: UIViewController..., from parent: UIViewController) {
        parent.navigationController?.pushViewController(target.first!, animated: true)
    }
}

public struct ModalPresenter: Presenting {
    public init() {}

    public func present(_ target: UIViewController..., from parent: UIViewController) {
        let statusBarVC = StatusBarViewController(target.first!)
        statusBarVC.modalPresentationStyle = .fullScreen
        parent.present(statusBarVC, animated: true)
    }
}

public struct ReplacePresenter: Presenting {
    public enum Mode {
        case replaceAll
        case replaceLast
        case replaceBackwards(AnyObject.Type)
    }

    var mode: Mode

    public init(mode: Mode = .replaceAll) {
        self.mode = mode
    }

    public func present(_ target: UIViewController..., from parent: UIViewController) {
        guard let navigationController = parent.navigationController else { return }

        switch mode {
        case .replaceAll:
            navigationController.setViewControllers(target, animated: true)

        case .replaceBackwards(let OlderInStack):
            if let oldScreen = navigationController.viewControllers.filter({ $0.isKind(of: OlderInStack.self) }).first,
               let index = navigationController.viewControllers.firstIndex(of: oldScreen) {

                let viewControllersBefore =
                    navigationController.viewControllers.dropLast(
                        navigationController.viewControllers.count - index
                    )

                if let coordinator = navigationController.transitionCoordinator {
                    coordinator.animate(alongsideTransition: nil) { _ in
                        navigationController.setViewControllers(viewControllersBefore + target , animated: true)
                    }
                } else {
                    navigationController.setViewControllers(viewControllersBefore + target , animated: true)
                }

            } else {
                navigationController.pushViewController(target.first!, animated: true)
            }
        case .replaceLast:
            let viewControllersBefore = navigationController.viewControllers.dropLast()

            func replace() {
                navigationController.setViewControllers(viewControllersBefore + target , animated: true)
            }

            if let coordinator = navigationController.transitionCoordinator {
                coordinator.animate(alongsideTransition: nil) { _ in
                    replace()
                }
            } else {
                replace()
            }
        }
    }
}

public struct PopReplacePresenter: Presenting {
    public init() {}

    public func present(_ target: UIViewController..., from parent: UIViewController) {
        if let lastViewController = parent.navigationController?.viewControllers.last {
            parent.navigationController?.setViewControllers([target.first!, lastViewController], animated: false)
            parent.navigationController?.setViewControllers([target.first!], animated: true)
        }
    }
}
