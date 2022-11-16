import UIKit
import Shared
import Combine
import AppResources

public final class DrawerSwitch: DrawerItem {
  public var isOnPublisher: AnyPublisher<Bool, Never> {
    isOnSubject.eraseToAnyPublisher()
  }

  private let title: String
  private let content: String
  private let isEnabled: Bool
  private let isInitiallyOn: Bool
  private var cancellables = Set<AnyCancellable>()
  private let isOnSubject: CurrentValueSubject<Bool, Never>

  public var spacingAfter: CGFloat? = 0

  public init(
    title: String,
    content: String,
    isEnabled: Bool = true,
    spacingAfter: CGFloat = 10,
    isInitiallyOn: Bool = false
  ) {
    self.title = title
    self.content = content
    self.isEnabled = isEnabled
    self.spacingAfter = spacingAfter
    self.isInitiallyOn = isInitiallyOn
    self.isOnSubject = .init(isInitiallyOn)
  }

  public func makeView() -> UIView {
    let view = UIView()
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let switcherView = UISwitch()

    titleLabel.text = title
    contentLabel.text = content

    switcherView.isOn = isInitiallyOn
    switcherView.isEnabled = isEnabled
    switcherView.onTintColor = Asset.brandPrimary.color

    titleLabel.textColor = Asset.neutralWeak.color
    contentLabel.textColor = Asset.neutralActive.color

    titleLabel.font = Fonts.Mulish.bold.font(size: 12.0)
    contentLabel.font = Fonts.Mulish.regular.font(size: 16.0)

    view.addSubview(titleLabel)
    view.addSubview(contentLabel)
    view.addSubview(switcherView)

    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
    }

    contentLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(5)
      $0.left.equalToSuperview()
      $0.bottom.equalToSuperview()
    }

    switcherView.snp.makeConstraints {
      $0.right.equalToSuperview()
      $0.centerY.equalToSuperview()
    }

    switcherView.publisher(for: .valueChanged)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in isOnSubject.send(switcherView.isOn) }
      .store(in: &cancellables)

    return view
  }
}
