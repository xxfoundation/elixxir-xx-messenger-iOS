import UIKit
import Models
import Shared

final class MembersController: UIViewController {
    lazy private var stackView = UIStackView()

    private let members: [GroupMember]

    init(with members: [GroupMember]) {
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

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        for member in members {
            let memberView = MemberView()
            memberView.titleLabel.text = member.username
            memberView.avatarView.set(username: member.username, image: member.photo)
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

        avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
            make.left.equalToSuperview().offset(25)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.left.equalTo(avatarView.snp.right).offset(14)
            make.right.lessThanOrEqualToSuperview().offset(-10)
        }

        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
