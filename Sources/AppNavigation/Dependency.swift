import Dependencies
import XCTestDynamicOverlay

public enum NavigatorKey: TestDependencyKey {
  public static let testValue: Navigator = UnimplementedNavigator()
}

public extension DependencyValues {
  var navigator: Navigator {
    get { self[NavigatorKey.self] }
    set { self[NavigatorKey.self] = newValue }
  }
}

public struct UnimplementedNavigator: Navigator {
  public init() {}

  public func perform(_ action: Action, completion: @escaping () -> Void) {
    XCTestDynamicOverlay.XCTFail("UnimplementedNavigator.perform not implemented")
  }

  public func canPerform(_ action: Action) -> Bool {
    XCTestDynamicOverlay.XCTFail("UnimplementedNavigator.canPerform not implemented")
    return false
  }
}
