import UIKit
import Shared
import AppResources

final class ProfileView: UIView {
  let stackView = UIStackView()
  let cardComponent = AvatarCardComponent()
  let emailView = AttributeComponent()
  let phoneView = AttributeComponent()

  init() {
    super.init(frame: .zero)
    backgroundColor = Asset.neutralWhite.color

    let emailTitle = Localized.Profile.Email.title
    let phoneTitle = Localized.Profile.Phone.title

    emailView.set(title: emailTitle, style: .interactive)
    phoneView.set(title: phoneTitle, style: .interactive)

    stackView.spacing = 41
    stackView.axis = .vertical
    stackView.addArrangedSubview(emailView)
    stackView.addArrangedSubview(phoneView)

    addSubview(stackView)
    addSubview(cardComponent)

    cardComponent.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
    }

    stackView.snp.makeConstraints {
      $0.top.equalTo(cardComponent.snp.bottom).offset(24)
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-26)
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }
}
