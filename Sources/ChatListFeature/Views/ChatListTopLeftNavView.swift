import UIKit
import Shared
import Combine
import AppResources

final class ChatListTopLeftNavView: UIView {
  let titleLabel = UILabel()
  let badgeLabel = UILabel()
  let menuButton = UIButton()
  let stackView = UIStackView()
  let badgeContainerView = UIView()
  
  var actionPublisher: AnyPublisher<Void, Never> {
    actionSubject.eraseToAnyPublisher()
  }
  
  private let actionSubject = PassthroughSubject<Void, Never>()
  
  init() {
    super.init(frame: .zero)
    
    titleLabel.text = Localized.ChatList.title
    titleLabel.textColor = Asset.neutralActive.color
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)
    
    menuButton.tintColor = Asset.neutralDark.color
    menuButton.setImage(Asset.chatListMenu.image, for: .normal)
    menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
    
    badgeLabel.textColor = Asset.neutralWhite.color
    badgeLabel.font = Fonts.Mulish.bold.font(size: 12.0)
    
    badgeContainerView.layer.cornerRadius = 5
    badgeContainerView.layer.masksToBounds = true
    badgeContainerView.backgroundColor = Asset.brandPrimary.color
    
    badgeContainerView.addSubview(badgeLabel)
    menuButton.addSubview(badgeContainerView)
    stackView.addArrangedSubview(menuButton)
    stackView.addArrangedSubview(titleLabel)
    addSubview(stackView)
    
    badgeLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(3)
      $0.center.equalToSuperview()
      $0.left.equalToSuperview().offset(3)
    }
    badgeContainerView.snp.makeConstraints {
      $0.centerY.equalTo(menuButton.snp.top)
      $0.centerX.equalTo(menuButton.snp.right).multipliedBy(0.8)
    }
    menuButton.snp.makeConstraints {
      $0.width.equalTo(50)
    }
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) { nil }
  
  @objc private func didTapMenu() {
    actionSubject.send()
  }
  
  func updateBadge(_ count: Int) {
    guard count > 0 else {
      badgeContainerView.isHidden = true
      return
    }
    
    badgeLabel.text = "\(count)"
    badgeContainerView.isHidden = false
  }
}
