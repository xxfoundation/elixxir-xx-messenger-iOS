import UIKit

/// Presents `UIActivityViewController` on a given parent view controller
public struct PresentActivitySheet: Action {
  /// - Parameters:
  ///   - items: Items to be displayed at the activity sheet controller
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    items: [Any],
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.items = items
    self.parent = parent
    self.animated = animated
  }

  /// Items to be displayed at the activity sheet controller
  public var items: [Any]

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentActivitySheet` action
public struct PresentActivitySheetNavigator: TypedNavigator {
  public init() {}

  public func perform(_ action: PresentActivitySheet, completion: @escaping () -> Void) {
    action.parent.present(
      UIActivityViewController(
        activityItems: action.items,
        applicationActivities: nil
      ),
      animated: action.animated,
      completion: completion
    )
  }
}
