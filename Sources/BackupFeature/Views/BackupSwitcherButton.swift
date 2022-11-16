import UIKit
import Shared
import AppResources

final class BackupSwitcherButton: UIControl {
  let titleLabel = UILabel()
  let separatorView = UIView()
  let switcherView = UISwitch()
  let logoImageView = UIImageView()
  let chevronImageView = UIImageView()

  init() {
    super.init(frame: .zero)

    titleLabel.textColor = Asset.neutralActive.color
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 16.0)

    switcherView.onTintColor = Asset.brandLight.color
    chevronImageView.image = Asset.settingsDisclosure.image
    separatorView.backgroundColor = Asset.neutralLine.color

    addSubview(separatorView)
    addSubview(logoImageView)
    addSubview(titleLabel)
    addSubview(switcherView)
    addSubview(chevronImageView)

    logoImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.left.equalToSuperview().offset(36)
      make.bottom.equalToSuperview().offset(-20)
    }

    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(logoImageView.snp.right).offset(15)
      make.centerY.equalTo(logoImageView)
    }

    chevronImageView.snp.makeConstraints { make in
      make.centerY.equalTo(logoImageView)
      make.right.equalToSuperview().offset(-48)
    }

    switcherView.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-25)
      make.centerY.equalTo(logoImageView)
    }

    separatorView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.height.equalTo(1)
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
    }
  }

  required init?(coder: NSCoder) { nil }

  func showSwitcher(enabled: Bool) {
    switcherView.isOn = enabled
    switcherView.isHidden = false
    chevronImageView.isHidden = true
  }

  func showChevron() {
    switcherView.isOn = false
    switcherView.isHidden = true
    chevronImageView.isHidden = false
  }
}
