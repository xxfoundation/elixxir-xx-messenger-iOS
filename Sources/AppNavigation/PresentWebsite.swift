import UIKit
import WebKit

/// Presents `Website` on a given parent view controller
public struct PresentWebsite: Action {
  /// - Parameters:
  ///   - urlString: Url that will be loaded on the web view
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    urlString: String,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.urlString = urlString
    self.parent = parent
    self.animated = animated
  }

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Url that will be loaded on the web view
  public var urlString: String

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentWebsite` action
public struct PresentWebsiteNavigator: TypedNavigator {
  /// View controller which should be presented
  var viewController: (String) -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be presented
  public init(_ viewController: @escaping (String) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentWebsite, completion: @escaping () -> Void) {
    action.parent.present(
      UINavigationController(
        rootViewController: viewController(action.urlString)
      ),
      animated: action.animated,
      completion: completion
    )
  }
}
