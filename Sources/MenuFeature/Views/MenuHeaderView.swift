import UIKit
import Shared
import AppResources

final class MenuHeaderView: UIView {
    let nameButton = UIButton()
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

        nameButton.titleLabel?.font = Fonts.Mulish.bold.font(size: 18.0)
        nameButton.setTitleColor(Asset.neutralLine.color, for: .normal)

        let spacingView = UIView()
        verticalStackView.axis = .vertical
        verticalStackView.addArrangedSubview(spacingView)
        verticalStackView.addArrangedSubview(helloLabel)
        verticalStackView.addArrangedSubview(nameButton.pinning(at: .left(0)))

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
        nameButton.setTitle(username, for: .normal)
        avatarView.setupProfile(title: username, image: image, size: .large)
    }
}
