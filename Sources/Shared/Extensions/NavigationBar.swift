import UIKit

public extension UINavigationBar {
    func customize(
        translucent: Bool = false,
        backgroundColor: UIColor = .clear,
        shadowColor: UIColor? = nil
    ) {
        isTranslucent = translucent
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = backgroundColor
        barAppearance.backgroundEffect = .none
        barAppearance.shadowColor = shadowColor
        standardAppearance = barAppearance
        scrollEdgeAppearance = standardAppearance
    }
}
