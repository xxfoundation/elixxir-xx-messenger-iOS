import UIKit

/// Opens up `ChatMore` on a given parent view controller
public struct PresentChatMore: Action {
  /// - Parameters:
  ///   - didTapClear: Closure that will get called once the user taps on `clear`
  ///   - didTapReport: Closure that will get called once the user taps on `report`
  ///   - didTapDetails: Closure that will get called once the user taps on `details`
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    didTapClear: @escaping () -> Void,
    didTapReport: @escaping () -> Void,
    didTapDetails: @escaping () -> Void,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.didTapClear = didTapClear
    self.didTapReport = didTapReport
    self.didTapDetails = didTapDetails
    self.parent = parent
    self.animated = animated
  }

  /// Closure that will get called once the user taps on `clear`
  public var didTapClear: () -> Void

  /// Closure that will get called once the user taps on `report`
  public var didTapReport: () -> Void

  /// Closure that will get called once the user taps on `details`
  public var didTapDetails: () -> Void

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentChatMore` action
public struct PresentChatMoreNavigator: TypedNavigator {
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

  public func perform(_ action: PresentChatMore, completion: @escaping () -> Void) {
    let controller = viewController(
      action.didTapClear,
      action.didTapReport,
      action.didTapDetails
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
