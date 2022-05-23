import UIKit

public struct DrawerImage: DrawerItem {
    private let image: UIImage
    private let contentMode: UIView.ContentMode

    public var spacingAfter: CGFloat? = 0

    public init(
        image: UIImage,
        contentMode: UIView.ContentMode = .center,
        spacingAfter: CGFloat = 10
    ) {
        self.image = image
        self.contentMode = contentMode
        self.spacingAfter = spacingAfter
    }

    public func makeView() -> UIView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = contentMode
        return imageView
    }
}
