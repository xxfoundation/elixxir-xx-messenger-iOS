import UIKit
import Shared
import AppResources

final class OnboardingStartView: UIView {
  let titleLabel = UILabel()
  let stackView = UIStackView()
  let logoImageView = UIImageView()
  let startButton = CapsuleButton()
  let bottomImageView = UIImageView()
  let gradientLayer = CAGradientLayer.xxGradient()

  init() {
    super.init(frame: .zero)
    backgroundColor = Asset.neutralWhite.color
    logoImageView.image = Asset.onboardingLogoStart.image
    bottomImageView.image = Asset.onboardingBottomLogoStart.image

    titleLabel.textAlignment = .center
    titleLabel.textColor = Asset.neutralWhite.color
    titleLabel.font = Fonts.Mulish.bold.font(size: 18.0)
    titleLabel.text = Localized.Onboarding.Start.title
    startButton.set(style: .white, title: Localized.Onboarding.Start.action)

    logoImageView.contentMode = .center
    bottomImageView.contentMode = .center

    stackView.spacing = 40
    stackView.axis = .vertical
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(startButton)
    stackView.addArrangedSubview(bottomImageView)
    stackView.setCustomSpacing(70, after: startButton)

    addSubview(logoImageView)
    addSubview(stackView)

    layer.insertSublayer(gradientLayer, at: 0)

    logoImageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(130)
      $0.centerX.equalToSuperview()
    }
    stackView.snp.makeConstraints {
      $0.left.equalToSuperview().offset(40)
      $0.right.equalToSuperview().offset(-40)
      $0.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
    }
  }

  required init?(coder: NSCoder) { nil }
}
