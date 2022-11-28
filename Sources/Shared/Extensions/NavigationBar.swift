import UIKit
import AppResources

public extension UINavigationBar {
  func customize(
    translucent: Bool = false,
    backgroundColor: UIColor = .clear,
    shadowColor: UIColor? = nil,
    tint: UIColor = Asset.neutralActive.color
  ) {
    isTranslucent = translucent
    let barAppearance = UINavigationBarAppearance()
    barAppearance.backgroundColor = backgroundColor
    barAppearance.backgroundEffect = .none
    barAppearance.shadowColor = shadowColor
    
    tintColor = tint
    compactAppearance = barAppearance
    standardAppearance = barAppearance
    scrollEdgeAppearance = barAppearance
  }
}
