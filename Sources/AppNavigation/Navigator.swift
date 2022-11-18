/// Navigator that performs a navigation action
public protocol Navigator {
  /// Returns true if the navigator can perform the action
  /// - Default implementation returns true for any action
  /// - Parameter action: navigation action
  func canPerform(_ action: Action) -> Bool

  /// Performs the navigation action
  /// - Parameters:
  ///   - action: navigation action
  ///   - completion: closure that will be executed after performing the action
  func perform(_ action: Action, completion: @escaping () -> Void)
}

public extension Navigator {
  func canPerform(_ action: Action) -> Bool { true }

  /// Performs the navigation action with empty completion closure
  /// - Parameter action: navigation action
  func perform(_ action: Action) {
    perform(action, completion: {})
  }
}
