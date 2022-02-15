import UIKit

public protocol PopupStackItem {
    var spacingAfter: CGFloat? { get }

    func makeView() -> UIView
}

public extension PopupStackItem {
    var spacingAfter: CGFloat? { nil }
}
