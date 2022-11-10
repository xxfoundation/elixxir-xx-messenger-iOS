import UIKit

final class ChatSearchListContainerView: UIView {
  let emptyView = ChatSearchEmptyView()

  init() {
    super.init(frame: .zero)

    addSubview(emptyView)

    emptyView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }
}
