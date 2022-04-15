import UIKit
import Shared

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

        separatorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(1)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        restoreButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(34)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
