import UIKit
import Shared
import Models

final class GroupHeaderView: UIView {
    let container = UIView()
    let title = UILabel()
    let stack = UIStackView()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    func setup(title: String, members: [GroupMember]) {
        self.title.text = title

        for member in members {
            let avatar = AvatarView()
            avatar.set(
                cornerRadius: 25/2.0,
                fontSize: 10.0,
                username: member.username,
                image: member.photo
            )

            avatar.layer.borderWidth = 3
            avatar.layer.borderColor = UIColor.white.cgColor

            avatar.snp.makeConstraints { $0.width.height.equalTo(25.0) }
            stack.addArrangedSubview(avatar)
        }
    }

    private func setup() {
        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 15.0)

        container.addSubview(title)
        container.addSubview(stack)
        stack.spacing = -8

        title.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }

        stack.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }

        addSubview(container)
        container.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
