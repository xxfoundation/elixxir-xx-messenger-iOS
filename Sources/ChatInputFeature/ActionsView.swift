import UIKit
import Shared

final class ActionsView: UIView {

    let stack = UIStackView()
    let cameraButton = ActionButton()
    let libraryButton = ActionButton()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        cameraButton.setup(
            title: Localized.Chat.Actions.camera,
            image: Asset.chatInputActionCamera.image
        )

        libraryButton.setup(
            title: Localized.Chat.Actions.gallery,
            image: Asset.chatInputActionGallery.image
        )

        stack.spacing = 33
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.addArrangedSubview(cameraButton)
        stack.addArrangedSubview(libraryButton)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
