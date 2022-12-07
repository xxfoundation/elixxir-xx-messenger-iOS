import UIKit
import XXModels

public final class GroupMembersController: UIViewController {
  private lazy var screenView = GroupMembersView()

  private let groupInfo: GroupInfo
  
  public init(_ groupInfo: GroupInfo) {
    self.groupInfo = groupInfo
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()

    groupInfo.members.forEach {
      screenView.addMember(
        title: ($0.nickname ?? $0.username) ?? "Fetching username...",
        photo: $0.photo
      )
    }
  }
}
