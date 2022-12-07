import UIKit

/// Opens up `RetryMessage` on a given parent view controller
public struct PresentRetryMessage: Action {
  /// - Parameters:
  ///   - didTapRetry: Closure that will get called once the user taps on `retry`
  ///   - didTapDelete: Closure that will get called once the user taps on `delete`
  ///   - didTapCancel: Closure that will get called once the user taps on `cancel`
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    didTapRetry: @escaping () -> Void,
    didTapDelete: @escaping () -> Void,
    didTapCancel: @escaping () -> Void,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.didTapRetry = didTapRetry
    self.didTapDelete = didTapDelete
    self.didTapCancel = didTapCancel
    self.parent = parent
    self.animated = animated
  }

  /// Closure that will get called once the user taps on `retry`
  public var didTapRetry: () -> Void

  /// Closure that will get called once the user taps on `delete`
  public var didTapDelete: () -> Void

  /// Closure that will get called once the user taps on `cancel`
  public var didTapCancel: () -> Void

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentRetryMessage` action
public struct PresentRetryMessageNavigator: TypedNavigator {
  /// Custom transitioning delegate
  let transitioningDelegate = BottomTransitioningDelegate()

  /// View controller which should be opened up
  var viewController: (
    @escaping () -> Void,
    @escaping () -> Void,
    @escaping () -> Void
  ) -> UIViewController

  /// - Parameters:
  ///   - viewController: view controller which should be presented
  public init(_ viewController: @escaping (
    @escaping () -> Void,
    @escaping () -> Void,
    @escaping () -> Void
  ) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentRetryMessage, completion: @escaping () -> Void) {
    let controller = viewController(
      action.didTapRetry,
      action.didTapDelete,
      action.didTapCancel
    )
    controller.transitioningDelegate = transitioningDelegate
    controller.modalPresentationStyle = .overFullScreen

    action.parent.present(
      controller,
      animated: action.animated,
      completion: completion
    )
  }
}
