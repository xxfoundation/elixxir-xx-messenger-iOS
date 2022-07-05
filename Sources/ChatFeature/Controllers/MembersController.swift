import UIKit
import Models
import Shared
import XXModels

final class MembersController: UIViewController {
    lazy private var stackView = UIStackView()

    private let members: [Contact]

    init(with members: [Contact]) {
        self.members = members
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.backgroundColor = Asset.neutralWhite.color

        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        view.addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        members.forEach {
            let memberView = MemberView()
            let assignedTitle = ($0.nickname ?? $0.username) ?? "Fetching username..."
            memberView.titleLabel.text = assignedTitle
            memberView.avatarView.setupProfile(title: assignedTitle, image: $0.photo, size: .small)
            stackView.addArrangedSubview(memberView)
        }
    }
}

private final class MemberView: UIView {
    let titleLabel = UILabel()
    let avatarView = AvatarView()
    let separatorView = UIView()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color
        titleLabel.textColor = Asset.neutralBody.color
        titleLabel.font = Fonts.Mulish.bold.font(size: 12.0)
        separatorView.backgroundColor = Asset.neutralLine.color

        addSubview(titleLabel)
        addSubview(avatarView)
        addSubview(separatorView)

        avatarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.width.height.equalTo(30)
            $0.left.equalToSuperview().offset(25)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(avatarView)
            $0.left.equalTo(avatarView.snp.right).offset(14)
            $0.right.lessThanOrEqualToSuperview().offset(-10)
        }

        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.left.equalToSuperview().offset(25)
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
