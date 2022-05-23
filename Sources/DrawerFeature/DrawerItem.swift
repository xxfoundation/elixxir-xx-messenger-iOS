import UIKit

public protocol DrawerItem {
    var spacingAfter: CGFloat? { get }

    func makeView() -> UIView
}

public extension DrawerItem {
    var spacingAfter: CGFloat? { nil }
}
