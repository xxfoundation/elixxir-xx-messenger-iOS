import UIKit
import Shared

final class MenuHeaderView: UIView {
    let nameLabel = UILabel()
    let scanButton = UIButton()
    let stackView = UIStackView()
    let avatarView = AvatarView()
    let verticalStackView = UIStackView()

    init() {
        super.init(frame: .zero)

        let helloLabel = UILabel()
        helloLabel.text = Localized.Menu.title
        helloLabel.textColor = Asset.neutralWeak.color
        helloLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        nameLabel.textColor = Asset.neutralLine.color
        nameLabel.font = Fonts.Mulish.bold.font(size: 18.0)

        let spacingView = UIView()
        verticalStackView.axis = .vertical
        verticalStackView.addArrangedSubview(spacingView)
        verticalStackView.addArrangedSubview(helloLabel)
        verticalStackView.addArrangedSubview(nameLabel.pinning(at: .top(0)))

        verticalStackView.setCustomSpacing(15, after: spacingView)
        verticalStackView.setCustomSpacing(5, after: helloLabel)

        scanButton.layer.cornerRadius = 14
        scanButton.snp.makeConstraints { $0.width.height.equalTo(40) }
        scanButton.setImage(Asset.menuScan.image, for: .normal)
        scanButton.backgroundColor = Asset.neutralBody.color

        stackView.spacing = 15
        stackView.addArrangedSubview(avatarView)
        stackView.addArrangedSubview(verticalStackView)
        stackView.addArrangedSubview(scanButton.pinning(at: .top(0)))

        addSubview(stackView)

        avatarView.snp.makeConstraints { $0.width.height.equalTo(70) }
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) { nil  }

    func set(username: String, image: Data? = nil) {
        nameLabel.text = username
        avatarView.set(username: username, image: image)
    }
}
