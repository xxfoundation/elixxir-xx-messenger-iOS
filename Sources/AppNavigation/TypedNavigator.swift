/// Navigation that can perform action of a concrete type
public protocol TypedNavigator: Navigator {
  /// Type of the action that the navigator can perform
  associatedtype ActionType: Action

  /// Returns true if the action can be performed by the navigator
  /// - Default implementation returns true for any action
  /// - Parameter action: navigation action
  func canPerform(_ action: ActionType) -> Bool

  /// Performs the navigation action
  /// - Parameters:
  ///   - action: navigation action
  ///   - completion: closure that will be executed after performing the action
  func perform(_ action: ActionType, completion: @escaping () -> Void)
}

public extension TypedNavigator {
  /// Returns true if the navigation action is of the type handled by the navigator
  /// - Parameter action: navigation action
  /// - Returns: true if action can be performed
  func canPerform(_ action: Action) -> Bool {
    if let action = action as? ActionType {
      return canPerform(action)
    }
    return false
  }

  func canPerform(_ action: ActionType) -> Bool { true }

  /// Performs the navigation action with empty completion closure
  /// - Parameter action: navigation action
  func perform(_ action: ActionType) {
    perform(action, completion: {})
  }

  /// Performs the navigation action if its type matches `ActionType` handled by the navigator
  /// - Parameters:
  ///   - action: navigation action
  ///   - completion: closure that will be executed after performing the action
  func perform(_ action: Action, completion: @escaping () -> Void) {
    if let action = action as? ActionType {
      perform(action, completion: completion)
    }
  }
}
