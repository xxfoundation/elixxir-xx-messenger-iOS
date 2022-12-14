import UIKit
import ScrollViewController

/// Opens up `Nickname` on a given parent view controller
public struct PresentNickname: Action {
  /// - Parameters:
  ///   - prefilled: Optional value to be set as placeholder/pre-existent text
  ///   - completion: Closure that passes the value of the text set
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    prefilled: String,
    completion: @escaping (String) -> Void,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.prefilled = prefilled
    self.completion = completion
    self.parent = parent
    self.animated = animated
  }

  /// Value to be set as placeholder/pre-existent text
  public var prefilled: String

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
  let transitioningDelegate = FullscreenTransitioningDelegate()

  /// View controller which should be opened up
  var viewController: (String, @escaping (String) -> Void) -> UIViewController

  /// - Parameters:
  ///   - viewController: view controller which should be presented
  public init(_ viewController: @escaping (String, @escaping (String) -> Void) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentNickname, completion: @escaping () -> Void) {
    let scrollViewController = ScrollViewController()
    let controller = viewController(action.prefilled, action.completion)
    scrollViewController.addChild(controller)
    scrollViewController.contentView = controller.view
    scrollViewController.wrapperView.handlesTouchesOutsideContent = false
    scrollViewController.wrapperView.alignContentToBottom = true
    scrollViewController.scrollView.bounces = false
    controller.didMove(toParent: scrollViewController)
    scrollViewController.transitioningDelegate = transitioningDelegate
    scrollViewController.modalPresentationStyle = .overFullScreen

    action.parent.present(
      scrollViewController,
      animated: action.animated,
      completion: completion
    )
  }
}
