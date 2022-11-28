import Foundation

public extension NSError {
  static func create(_ string: String) -> NSError {
    NSError(
      domain: "Internal error",
      code: 0,
      userInfo: [NSLocalizedDescriptionKey: NSLocalizedString(string, comment: "")]
    )
  }
}
