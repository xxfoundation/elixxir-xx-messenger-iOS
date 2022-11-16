import UIKit
import Shared
import AppResources

final class OnboardingUsernameRestoreView: UIView {
  let titleLabel = UILabel()
  let restoreButton = CapsuleButton()
  let separatorView = UIView()

  init() {
    super.init(frame: .zero)

    titleLabel.text = Localized.Onboarding.Username.Restore.title
    restoreButton.set(style: .seeThrough, title: Localized.Onboarding.Username.Restore.action)

    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.font = Fonts.Mulish.bold.font(size: 24)

    addSubview(titleLabel)
    addSubview(restoreButton)
    addSubview(separatorView)

    separatorView.backgroundColor = Asset.neutralLine.color

    separatorView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
      $0.height.equalTo(1)
    }
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(separatorView.snp.bottom).offset(40)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    restoreButton.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(34)
      $0.left.equalToSuperview().offset(40)
      $0.right.equalToSuperview().offset(-40)
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }
}
