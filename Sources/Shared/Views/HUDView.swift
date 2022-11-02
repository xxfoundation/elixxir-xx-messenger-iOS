import UIKit
import Combine

final class HUDView: UIView {
  let titleLabel = UILabel()
  let contentLabel = UILabel()
  let stackView = UIStackView()
  let backgroundView = UIView()
  let actionButton = CapsuleButton()
  let animationView = DotAnimation()
  var cancellables = Set<AnyCancellable>()

  init() {
    super.init(frame: .zero)
    stackView.spacing = 20
    stackView.axis = .vertical

    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.textColor = Asset.neutralWhite.color
    titleLabel.font = Fonts.Mulish.bold.font(size: 30.0)

    contentLabel.numberOfLines = 0
    contentLabel.textAlignment = .center
    contentLabel.textColor = Asset.neutralWhite.color
    contentLabel.font = Fonts.Mulish.regular.font(size: 15.0)

    animationView.setColor(Asset.neutralWhite.color)
    backgroundColor =  Asset.neutralDark.color.withAlphaComponent(0.9)

    addSubview(backgroundView)
    backgroundView.addSubview(stackView)

    backgroundView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview().offset(30)
      $0.right.equalToSuperview().offset(-30)
    }

    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(15)
      $0.left.equalToSuperview().offset(15)
      $0.right.equalToSuperview().offset(-15)
      $0.bottom.equalToSuperview().offset(-20)
    }
  }

  required init?(coder: NSCoder) { nil }

  func setup(model: HUDModel) -> HUDView {
    if let title = model.title {
      titleLabel.text = title
      stackView.addArrangedSubview(titleLabel)
    }
    if let content = model.content {
      contentLabel.text = content
      stackView.addArrangedSubview(contentLabel)
    }
    if model.hasDotAnimation {
      animationView.snp.makeConstraints {
        $0.height.equalTo(20)
      }
      stackView.addArrangedSubview(animationView)
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
      stackView.addArrangedSubview(actionButton)
    }
    return self
  }
}
