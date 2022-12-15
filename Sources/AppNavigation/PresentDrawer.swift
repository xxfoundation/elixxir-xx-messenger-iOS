import UIKit
import ScrollViewController

/// Opens up `Drawer` on a given parent view controller
public struct PresentDrawer: Action {
  /// - Parameters:
  ///   - items: Collection of drawer items that will be present on the view controller
  ///   - isDismissable: Flag that differentiates whether this presentation is dismissable on background touch
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    items: [Any],
    isDismissable: Bool,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.items = items
    self.isDismissable = isDismissable
    self.parent = parent
    self.animated = animated
  }

  /// Collection of drawer items that will be present on the view controller
  public var items: [Any]

  /// Flag that differentiates whether this presentation is dismissable on background touch
  public var isDismissable: Bool

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentDrawer` action
public struct PresentDrawerNavigator: TypedNavigator {
  /// Custom transitioning delegate
  let transitioningDelegate = FullscreenTransitioningDelegate()

  /// View controller which should be opened up
  var viewController: ([Any]) -> UIViewController

  /// - Parameters:
  ///   - viewController: view controller which should be presented
  public init(_ viewController: @escaping ([Any]) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentDrawer, completion: @escaping () -> Void) {
    let scrollViewController = ScrollViewController()
    let controller = viewController(action.items)
    scrollViewController.addChild(controller)
    scrollViewController.contentView = controller.view
    scrollViewController.wrapperView.handlesTouchesOutsideContent = !action.isDismissable
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
