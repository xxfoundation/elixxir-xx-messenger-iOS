import UIKit
import Shared

public final class DrawerStack: DrawerItem {
    private let views: [UIView]
    private let spacing: CGFloat
    private let axis: NSLayoutConstraint.Axis
    private let distribution: UIStackView.Distribution

    public var spacingAfter: CGFloat? = 0

    public init(
        axis: NSLayoutConstraint.Axis = .horizontal,
        spacing: CGFloat = 10,
        spacingAfter: CGFloat = 10,
        distribution: UIStackView.Distribution = .fillEqually,
        views: [UIView]
    ) {
        self.axis = axis
        self.views = views
        self.spacing = spacing
        self.distribution = distribution
        self.spacingAfter = spacingAfter
    }
    
    public func makeView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = distribution
        stackView.addArrangedSubviews(views)
        return stackView
    }
}
