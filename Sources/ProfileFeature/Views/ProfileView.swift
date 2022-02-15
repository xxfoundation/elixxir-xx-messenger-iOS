import UIKit
import Shared

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

        cardComponent.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(cardComponent.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-26)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
