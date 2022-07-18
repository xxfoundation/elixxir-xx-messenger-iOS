import UIKit

public struct ViewConfigurator<View: UIView, Model> {
  public init(configure: @escaping (View, Model) -> Void) {
    self.configure = configure
  }

  public var configure: (View, Model) -> Void

  public func callAsFunction(view: View, with model: Model) {
    configure(view, model)
  }
}

#if DEBUG
extension ViewConfigurator {
  public static func failing() -> ViewConfigurator {
    ViewConfigurator { _, _ in fatalError("Not implemented") }
  }
}
#endif
