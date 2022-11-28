import UIKit
import Shared
import AppResources

final class AttributeSwitcher: UIView {
  struct State {
    var content: String
    var isVisible: Bool
  }

  private let titleLabel = UILabel()
  private let contentLabel = UILabel()
  private let stackView = UIStackView()
  private(set) var switcherView = UISwitch()
  private let verticalStackView = UIStackView()

  private(set) var addButton: UIControl = {
    let label = UILabel()
    let icon = UIImageView()
    let control = UIControl()

    icon.image = Asset.scanAdd.image
    label.text = Localized.Scan.Display.Share.add
    label.textColor = Asset.brandPrimary.color

    control.addSubview(icon)
    control.addSubview(label)

    icon.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.width.equalTo(icon.snp.height)
    }

    label.snp.makeConstraints {
      $0.left.equalTo(icon.snp.right).offset(5)
      $0.top.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }

    return control
  }()

  public init() {
    super.init(frame: .zero)

    contentLabel.textColor = Asset.neutralActive.color
    titleLabel.textColor = Asset.neutralWeak.color
    switcherView.onTintColor = Asset.brandPrimary.color

    contentLabel.numberOfLines = 0
    contentLabel.font = Fonts.Mulish.regular.font(size: 16.0)
    titleLabel.font = Fonts.Mulish.bold.font(size: 12.0)

    addSubview(stackView)

    verticalStackView.spacing = 5
    verticalStackView.axis = .vertical
    verticalStackView.addArrangedSubview(titleLabel)
    verticalStackView.addArrangedSubview(contentLabel)

    switcherView.setContentCompressionResistancePriority(.required, for: .vertical)
    switcherView.setContentCompressionResistancePriority(.required, for: .horizontal)

    stackView.addArrangedSubview(verticalStackView)
    stackView.addArrangedSubview(FlexibleSpace())

    let otherHStack = UIStackView()
    otherHStack.addArrangedSubview(addButton)
    otherHStack.addArrangedSubview(switcherView)

    let otherVStack = UIStackView()
    otherVStack.axis = .vertical
    otherVStack.addArrangedSubview(otherHStack)
    otherVStack.addArrangedSubview(FlexibleSpace())

    stackView.addArrangedSubview(otherVStack)

    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }

  func setup(state: State?, title: String) {
    titleLabel.text = title

    guard let state = state else {
      addButton.isHidden = false
      switcherView.isHidden = true
      contentLabel.text = Localized.Scan.Display.Share.notAdded
      return
    }

    addButton.isHidden = true
    switcherView.isHidden = false
    switcherView.isOn = state.isVisible
    contentLabel.text = state.isVisible ? state.content : Localized.Scan.Display.Share.hidden
  }
}
