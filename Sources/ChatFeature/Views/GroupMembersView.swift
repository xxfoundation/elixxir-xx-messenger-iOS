import UIKit
import Shared
import AppResources

final class GroupMembersView: UIView {
  private let stackView = UIStackView()

  init() {
    super.init(frame: .zero)

    layer.cornerRadius = 40
    layer.masksToBounds = true
    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    backgroundColor = Asset.neutralWhite.color

    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    addSubview(stackView)

    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(20)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.bottom.equalToSuperview().offset(-50)
    }
  }

  required init?(coder: NSCoder) { nil }

  func addMember(title: String, photo: Data?) {
    let memberView = GroupMemberView()
    memberView.titleLabel.text = title
    memberView.avatarView.setupProfile(
      title: title,
      image: photo,
      size: .small
    )
    stackView.addArrangedSubview(memberView)
  }
}
