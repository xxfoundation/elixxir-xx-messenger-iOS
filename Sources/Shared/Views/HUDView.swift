import UIKit
import Combine

final class HUDView: UIView {
  let titleLabel = UILabel()
  let actionButton = CapsuleButton()
  let animationView = DotAnimation()
  var cancellables = Set<AnyCancellable>()

  init(model: HUDModel) {
    super.init(frame: .zero)

    titleLabel.textColor = Asset.neutralWhite.color
    backgroundColor =  Asset.neutralDark.color.withAlphaComponent(0.8)

    if let color = model.animationColor {
      animationView.setColor(color)
    }

    if let actionTitle = model.actionTitle {
      actionButton.set(
        style: .seeThroughWhite,
        title: actionTitle
      )
      actionButton
        .publisher(for: .touchUpInside)
        .sink { model.onTapClosure?() }
        .store(in: &cancellables)
    }
  }

  required init?(coder: NSCoder) { nil }
}
