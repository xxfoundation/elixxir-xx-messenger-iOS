import UIKit
import Shared

public final class PopupStackView: PopupStackItem {
    // MARK: Properties
    
    let views: [UIView]
    let spacing: CGFloat
    let axis: NSLayoutConstraint.Axis
    let distribution: UIStackView.Distribution
    
    public var spacingAfter: CGFloat? = 10
    
    // MARK: Lifecycle
    
    public init(
        axis: NSLayoutConstraint.Axis = .horizontal,
        spacing: CGFloat = 10,
        distribution: UIStackView.Distribution = .fillEqually,
        views: [UIView]
    ) {
        self.axis = axis
        self.views = views
        self.spacing = spacing
        self.distribution = distribution
    }
    
    // MARK: Builder
    
    public func makeView() -> UIView {
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        stack.distribution = distribution
        stack.addArrangedSubviews(views)
        return stack
    }
}
