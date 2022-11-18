import UIKit
import Shared
import AppResources

final class ReplyView: UIView {
    let space = UIView()
    let title = UILabel()
    let message = UILabel()
    let container = UIView()

    init() {
        super.init(frame: .zero)
        container.layer.cornerRadius = 4
        container.layer.masksToBounds = true

        message.numberOfLines = 2

        title.textColor = Asset.neutralBody.color
        message.textColor = Asset.neutralBody.color

        title.font = Fonts.Mulish.semiBold.font(size: 10.0)
        message.font = Fonts.Mulish.regular.font(size: 14.0)

        addSubview(container)
        container.addSubview(space)
        container.addSubview(title)
        container.addSubview(message)

        container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }

        space.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(space.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-8)
        }

        message.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(4)
            make.left.equalTo(title)
            make.right.equalTo(title)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) { nil }

    func cleanUp() {
        title.text = nil
        message.text = nil
    }
}
