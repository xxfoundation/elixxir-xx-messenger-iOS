import UIKit

/// Opens up `Nickname` on a given parent view controller
public struct PresentNickname: Action {
  /// - Parameters:
  ///   - prefilled: Optional value to be set as placeholder/pre-existent text
  ///   - completion: Closure that passes the value of the text set
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    prefilled: String?,
    completion: @escaping (String) -> Void,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.prefilled = prefilled
    self.completion = completion
    self.parent = parent
    self.animated = animated
  }

  /// Optional value to be set as placeholder/pre-existent text
  public var prefilled: String?

  /// Closure that passes the value of the text set
  public var completion: (String) -> Void

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentNickname` action
public struct PresentNicknameNavigator: TypedNavigator {
  /// Custom transitioning delegate
  let transitioningDelegate = BottomTransitioningDelegate()

  /// View controller which should be opened up
  var viewController: () -> UIViewController

  /// - Parameters:
  ///   - viewController: view controller which should be presented
  public init(_ viewController: @escaping () -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentNickname, completion: @escaping () -> Void) {
    let controller = viewController()
    controller.transitioningDelegate = transitioningDelegate
    controller.modalPresentationStyle = .overFullScreen

    action.parent.present(
      controller,
      animated: action.animated,
      completion: completion
    )
  }
}
