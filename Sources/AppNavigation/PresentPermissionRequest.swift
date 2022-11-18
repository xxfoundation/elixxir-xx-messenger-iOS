import UIKit

/// Types of permissions that can be requested to the user
public enum PermissionType {
  /// Device camera permission type
  case camera

  /// Camera roll and library permission type
  case library

  /// Device microphone permission type
  case microphone
}

/// Presents `PermissionRequest` on provided parent view controller
public struct PresentPermissionRequest: Action {
  /// - Parameters:
  ///   - type: Type of permission that is being requested
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    type: PermissionType,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.type = type
    self.parent = parent
    self.animated = animated
  }

  /// Type of permission that is being requested
  public var type: PermissionType

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentPermissionRequest` action
public struct PresentPermissionRequestNavigator: TypedNavigator {
  /// View controller which should be presented
  var viewController: (PermissionType) -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be presented
  public init(_ viewController: @escaping (PermissionType) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentPermissionRequest, completion: @escaping () -> Void) {
    action.parent.present(
      viewController(action.type),
      animated: action.animated,
      completion: completion
    )
  }
}
