import UIKit

public struct ToastModel {
    let id: UUID
    let title: String
    let color: UIColor
    let subtitle: String?
    let leftImage: UIImage
    let timeToLive: Int
    let buttonTitle: String?
    let autodismissable: Bool
    let onTapClosure: (() -> Void)?

    public init(
        id: UUID = UUID(),
        title: String,
        color: UIColor = Asset.neutralOverlay.color,
        subtitle: String? = nil,
        leftImage: UIImage,
        timeToLive: Int = 4,
        buttonTitle: String? = nil,
        onTapClosure: (() -> Void)? = nil,
        autodismissable: Bool = true
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.subtitle = subtitle
        self.leftImage = leftImage
        self.timeToLive = timeToLive
        self.buttonTitle = buttonTitle
        self.onTapClosure = onTapClosure
        self.autodismissable = autodismissable
    }
}
