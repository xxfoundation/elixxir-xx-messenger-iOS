import UIKit
import Shared

final class SettingsSwitcher: UIView {
  let titleLabel = UILabel()
  let textLabel = UILabel()
  let iconImageView = UIImageView()
  let separatorView = UIView()
  let switcherView = UISwitch()
  let stackView = UIStackView()
  let verticalStackView = UIStackView()

  init() {
    super.init(frame: .zero)

    textLabel.textColor = Asset.neutralWeak.color
    titleLabel.textColor = Asset.neutralActive.color
    switcherView.onTintColor = Asset.brandPrimary.color
    separatorView.backgroundColor = Asset.neutralLine.color

    iconImageView.contentMode = .center
    iconImageView.setContentHuggingPriority(.required, for: .horizontal)

    textLabel.numberOfLines = 0
    textLabel.font = Fonts.Mulish.regular.font(size: 12.0)
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

    addSubview(stackView)
    addSubview(separatorView)

    verticalStackView.spacing = 3
    verticalStackView.axis = .vertical
    verticalStackView.addArrangedSubview(titleLabel)
    verticalStackView.addArrangedSubview(textLabel)

    let icon = iconImageView.pinning(at: .top(0))

    stackView.spacing = 8
    stackView.addArrangedSubview(icon)
    stackView.addArrangedSubview(verticalStackView)
    stackView.addArrangedSubview(switcherView.pinning(at: .top(0)))

    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(16)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-20)
    }
    separatorView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }

  func set(
    title: String,
    text: String? = nil,
    icon: UIImage? = nil,
    separator: Bool = true,
    extraAction: UIButton? = nil
  ) {
    titleLabel.text = title

    if let content = text {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.lineHeightMultiple = 1.5

      textLabel.attributedText = NSAttributedString(
        string: content, attributes: [.paragraphStyle: paragraphStyle]
      )
    } else {
      verticalStackView.removeArrangedSubview(textLabel)
    }

    if let icon = icon {
      iconImageView.image = icon
    } else {
      stackView.removeArrangedSubview(iconImageView)
    }

    if let button = extraAction {
      stackView.insertArrangedSubview(button.pinning(at: .top(0)), at: 2)
    }

    guard separator == true else {
      separatorView.removeFromSuperview()
      return
    }
  }
}

final class SettingsInfoSwitcher: UIView {
  let titleView = TextWithInfoView()
  let textLabel = UILabel()
  let iconImageView = UIImageView()
  let separatorView = UIView()
  let switcherView = UISwitch()
  let stackView = UIStackView()
  let verticalStackView = UIStackView()

  var didTapInfo: (() -> Void)?

  init() {
    super.init(frame: .zero)

    textLabel.textColor = Asset.neutralWeak.color
    switcherView.onTintColor = Asset.brandPrimary.color
    separatorView.backgroundColor = Asset.neutralLine.color

    iconImageView.contentMode = .center
    iconImageView.setContentHuggingPriority(.required, for: .horizontal)

    textLabel.numberOfLines = 0
    textLabel.font = Fonts.Mulish.regular.font(size: 12.0)
    textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    addSubview(stackView)
    addSubview(separatorView)

    let titleContainer = UIView()
    titleContainer.addSubview(titleView)
    titleView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(-10)
      $0.left.equalToSuperview().offset(-4)
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview().offset(10)
    }

    verticalStackView.spacing = 3
    verticalStackView.axis = .vertical
    verticalStackView.addArrangedSubview(titleContainer.pinning(at: .left(0)))
    verticalStackView.addArrangedSubview(textLabel)

    let icon = iconImageView.pinning(at: .top(0))

    let switcherContainer = UIView()
    switcherContainer.addSubview(switcherView)
    switcherView.setContentCompressionResistancePriority(.required, for: .horizontal)
    switcherContainer.setContentCompressionResistancePriority(.required, for: .horizontal)

    switcherView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }

    stackView.spacing = 8
    stackView.addArrangedSubview(icon)
    stackView.addArrangedSubview(verticalStackView)
    stackView.addArrangedSubview(switcherContainer)

    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(16)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-20)
    }
    separatorView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }

  func set(
    title: String,
    text: String? = nil,
    icon: UIImage? = nil,
    separator: Bool = true,
    extraAction: UIButton? = nil,
    didTapInfo: (() -> Void)? = nil
  ) {
    self.didTapInfo = didTapInfo

    titleView.setup(
      text: title,
      attributes: [
        .foregroundColor: Asset.neutralActive.color,
        .font: Fonts.Mulish.semiBold.font(size: 14.0) as Any
      ], didTapInfo: { self.didTapInfo?() }
    )

    if let content = text {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.lineHeightMultiple = 1.5

      textLabel.attributedText = NSAttributedString(
        string: content, attributes: [.paragraphStyle: paragraphStyle]
      )
    } else {
      verticalStackView.removeArrangedSubview(textLabel)
    }

    if let icon = icon {
      iconImageView.image = icon
    } else {
      stackView.removeArrangedSubview(iconImageView)
    }

    if let button = extraAction {
      stackView.insertArrangedSubview(button.pinning(at: .top(0)), at: 2)
    }

    guard separator == true else {
      separatorView.removeFromSuperview()
      return
    }
  }
}
