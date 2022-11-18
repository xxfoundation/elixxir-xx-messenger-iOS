/// Combines multiple navigators into a single one
///
/// - Action is performed using the first navigator that can handle it
/// - When there is no navigator that can handle given action, assertion is thrown
/// - When there are multiple navigators that can handle given action, assertion is thrown
public struct CombinedNavigator: Navigator {
  public init(_ navigators: Navigator...) {
    self.navigators = navigators
  }

  public init(_ navigators: [Navigator]) {
    self.navigators = navigators
  }

  public func perform(_ action: Action, completion: @escaping () -> Void) {
    let navigators = self.navigators.filter { $0.canPerform(action) }
    guard let firstNavigator = navigators.first else {
      assertionFailure("No navigator to perform action: \(action)", #file, #line)
      return
    }
    guard navigators.count == 1 else {
      assertionFailure("Multiple navigators can perform action: \(action), \(navigators)", #file, #line)
      return
    }
    firstNavigator.perform(action, completion: completion)
  }

  let navigators: [Navigator]
  var assertionFailure: (@autoclosure () -> String, StaticString, UInt) -> Void = Swift.assertionFailure
}
