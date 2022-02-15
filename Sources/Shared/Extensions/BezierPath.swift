import UIKit

public extension UIBezierPath {
    convenience init(_ size: CGSize, rad: CGFloat) {
        self.init(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: rad)
    }
}
