import UIKit

public struct PopupImage: PopupStackItem {
    // MARK: Properties

    let image: UIImage
    let contentMode: UIView.ContentMode
    public var spacingAfter: CGFloat? = 16

    // MARK: Lifecycle

    public init(
        image: UIImage,
        contentMode: UIView.ContentMode = .center
    ) {
        self.image = image
        self.contentMode = contentMode
    }

    // MARK: Builder

    public func makeView() -> UIView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = contentMode
        return imageView
    }
}
