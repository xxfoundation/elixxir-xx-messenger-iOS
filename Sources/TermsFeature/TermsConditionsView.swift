import UIKit
import Shared
import AppResources

final class TermsConditionsView: UIView {
  let nextButton = CapsuleButton()
  let logoImageView = UIImageView()
  let showTermsButton = CapsuleButton()
  let radioComponent = RadioTextComponent()
  let gradientLayer = CAGradientLayer.xxGradient()

  init() {
    super.init(frame: .zero)
    backgroundColor = Asset.neutralWhite.color

    logoImageView.contentMode = .center
    logoImageView.image = Asset.onboardingLogoStart.image
    radioComponent.titleLabel.text = Localized.Terms.radio

    nextButton.isEnabled = false
    nextButton.set(style: .white, title: Localized.Terms.accept)
    showTermsButton.set(style: .seeThroughWhite, title: Localized.Terms.show)

    addSubview(logoImageView)
    addSubview(nextButton)
    addSubview(radioComponent)
    addSubview(showTermsButton)

    layer.insertSublayer(gradientLayer, at: 0)

    logoImageView.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide).offset(30)
      $0.centerX.equalToSuperview()
    }
    radioComponent.snp.makeConstraints {
      $0.left.equalToSuperview().offset(40)
      $0.right.equalToSuperview().offset(-40)
      $0.bottom.equalTo(nextButton.snp.top).offset(-20)
    }
    nextButton.snp.makeConstraints {
      $0.left.equalToSuperview().offset(40)
      $0.right.equalToSuperview().offset(-40)
      $0.bottom.equalTo(showTermsButton.snp.top).offset(-10)
    }
    showTermsButton.snp.makeConstraints {
      $0.left.equalToSuperview().offset(40)
      $0.right.equalToSuperview().offset(-40)
      $0.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
    }
  }

  required init?(coder: NSCoder) { nil }
}
