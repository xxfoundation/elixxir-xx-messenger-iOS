import UIKit
import XCTestDynamicOverlay

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
  public static func unimplemented() -> ViewConfigurator {
    ViewConfigurator(configure: XCTUnimplemented("\(Self.self)"))
  }
}
#endif
