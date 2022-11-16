import Navigation
import Dependencies

private enum NavigatorKey: DependencyKey {
  static let liveValue: Navigator = CombinedNavigator.core
  static let testValue: Navigator = UnimplementedNavigator()
}

extension DependencyValues {
  var navigator: Navigator {
    get { self[NavigatorKey.self] }
    set { self[NavigatorKey.self] = newValue }
  }
}

import UIKit
import XCTestDynamicOverlay
import ComposableArchitecture

public struct PresentStep: Navigation.Action, Equatable {
  public init(viewController: UIViewController, from: UIViewController) {
    self.viewController = viewController
    self.from = from
  }

  public var viewController: UIViewController
  public var from: UIViewController
}

struct PresentStepNavigator: Navigation.TypedNavigator {
  @Dependency(\.navigator) var navigator

  func perform(_ action: PresentStep, completion: @escaping () -> Void) {
    guard let navigationController = action.from.navigationController else {
      completion()
      return
    }
    navigator.perform(
      SetStack(
        navigationController.viewControllers + [action.viewController],
        on: navigationController
      ),
      completion: completion
    )
  }
}

public struct DismissToStep: Navigation.Action, Equatable {
  public init(viewController: UIViewController) {
    self.viewController = viewController
  }

  public var viewController: UIViewController
}

struct DismissToStepNavigator: Navigation.TypedNavigator {
  @Dependency(\.navigator) var navigator

  func perform(_ action: DismissToStep, completion: @escaping () -> Void) {
    guard let navigationController = action.viewController.navigationController else {
      completion()
      return
    }
    navigator.perform(
      PopTo(action.viewController, on: navigationController),
      completion: completion
    )
  }
}

extension CombinedNavigator {
  public static let core = CombinedNavigator(
    SetStackNavigator(),
    PopToNavigator(),
    PresentStepNavigator(),
    DismissToStepNavigator()
  )
}

public struct UnimplementedNavigator: Navigator {
  public init() {}

  public func perform(_ action: Navigation.Action, completion: @escaping () -> Void) {
    XCTestDynamicOverlay.XCTFail("UnimplementedNavigator.perform not implemented")
  }

  public func canPerform(_ action: Action) -> Bool {
    XCTestDynamicOverlay.XCTFail("UnimplementedNavigator.canPerform not implemented")
    return false
  }
}
