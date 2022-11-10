import UIKit
import Shared

final class ChatListView: UIView {
  let snackBar = SnackBar()
  let containerView = UIView()
  let searchView = SearchComponent()
  let listContainerView = ChatListContainerView()
  let searchListContainerView = ChatSearchListContainerView()
  
  init() {
    super.init(frame: .zero)

    backgroundColor = Asset.neutralWhite.color
    listContainerView.backgroundColor = Asset.neutralWhite.color
    searchListContainerView.backgroundColor = Asset.neutralWhite.color
    searchView.update(placeholder: Localized.ChatList.Search.title)

    addSubview(snackBar)
    addSubview(searchView)
    addSubview(containerView)
    containerView.addSubview(searchListContainerView)
    containerView.addSubview(listContainerView)

    snackBar.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalTo(snp.top)
    }
    searchView.snp.makeConstraints {
      $0.top.equalTo(snackBar.snp.bottom).offset(20)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    containerView.snp.makeConstraints {
      $0.top.equalTo(searchView.snp.bottom)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    listContainerView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    searchListContainerView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) { nil }
  
  func showConnectingBanner(_ show: Bool) {
    if show == true {
      snackBar.alpha = 0.0
      snackBar.snp.updateConstraints {
        $0.bottom
          .equalTo(snp.top)
          .offset(snackBar.bounds.height)
      }
    } else {
      snackBar.alpha = 1.0
      snackBar.snp.updateConstraints {
        $0.bottom.equalTo(snp.top)
      }
    }
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
      self.setNeedsLayout()
      self.layoutIfNeeded()
      self.snackBar.alpha = show ? 1.0 : 0.0
    }
  }
}
