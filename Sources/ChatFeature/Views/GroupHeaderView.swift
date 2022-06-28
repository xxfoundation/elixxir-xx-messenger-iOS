import UIKit
import Shared

struct Member {
    let title: String
    let photo: Data?
}

final class GroupHeaderView: UIView {
    let titleLabel = UILabel()
    let containerView = UIView()
    let stackView = UIStackView()

    init() {
        super.init(frame: .zero)

        stackView.spacing = -8
        titleLabel.textColor = Asset.neutralActive.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 15.0)

        containerView.addSubview(titleLabel)
        containerView.addSubview(stackView)
        addSubview(containerView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview()
            $0.right.lessThanOrEqualToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview()
            $0.right.lessThanOrEqualToSuperview()
            $0.bottom.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    func setup(title: String, memberList: [Member]) {
        titleLabel.text = title

        memberList.forEach {
            let avatarView = AvatarView()
            avatarView.layer.borderWidth = 3
            avatarView.layer.borderColor = UIColor.white.cgColor
            avatarView.setupProfile(title: $0.title, image: $0.photo, size: .small)
            avatarView.snp.makeConstraints { $0.width.height.equalTo(25.0) }
            stackView.addArrangedSubview(avatarView)
        }
    }
}
