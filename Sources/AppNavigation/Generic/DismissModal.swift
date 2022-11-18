import UIKit

/// Dismiss view controller presented from provided view controller
public struct DismissModal: Action {
  /// - Parameters:
  ///   - parent: Parent view controller from which dismiss happens
  ///   - animated: Animate the transition
  public init(
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.parent = parent
    self.animated = animated
  }

  /// Parent view controller from which dismiss happens
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `DismissModal` action
public struct DismissModalNavigator: TypedNavigator {
  public init() {}

  public func perform(_ action: DismissModal, completion: @escaping () -> Void) {
    action.parent.dismiss(
      animated: action.animated,
      completion: completion
    )
  }
}
