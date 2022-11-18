import UIKit

/// Present view controller on provided parent view controller
public struct PresentModal: Action {
  /// - Parameters:
  ///   - viewController: View controller to present
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    _ viewController: UIViewController,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.viewController = viewController
    self.parent = parent
    self.animated = animated
  }

  /// View controller to present
  public var viewController: UIViewController

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentModal` action
public struct PresentModalNavigator: TypedNavigator {
  public init() {}

  public func perform(_ action: PresentModal, completion: @escaping () -> Void) {
    action.parent.present(
      action.viewController,
      animated: action.animated,
      completion: completion
    )
  }
}
