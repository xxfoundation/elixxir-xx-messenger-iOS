import UIKit

/// Presents `CountryList` on a given parent view controller
public struct PresentCountryList: Action {
  /// - Parameters:
  ///   - completion: Completion closure with the selected country model
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    completion: @escaping (Any) -> Void,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.completion = completion
    self.parent = parent
    self.animated = animated
  }

  /// Completion closure with the selected country model
  public var completion: (Any) -> Void

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentCountryList` action
public struct PresentCountryListNavigator: TypedNavigator {
  /// View controller which should be presented
  var viewController: (@escaping (Any) -> Void) -> UIViewController

  /// - Parameters:
  ///   - viewController: view controller which should be presented
  public init(_ viewController: @escaping (@escaping (Any) -> Void) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentCountryList, completion: @escaping () -> Void) {
    action.parent.present(
      viewController(action.completion),
      animated: action.animated,
      completion: completion
    )
  }
}
