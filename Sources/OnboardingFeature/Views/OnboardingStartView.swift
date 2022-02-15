import UIKit
import Shared

final class OnboardingStartView: UIView {
    let titleLabel = UILabel()
    let stackView = UIStackView()
    let logoImageView = UIImageView()
    let startButton = CapsuleButton()
    let bottomImageView = UIImageView()

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

        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(130)
            make.centerX.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
        }
    }

    required init?(coder: NSCoder) { nil }
}
