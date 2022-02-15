import UIKit
import Shared

final class SheetView: UIView {
    let stack = UIStackView()
    let clear = SheetButton()
    let details = SheetButton()

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 40
        layer.masksToBounds = true
        backgroundColor = Asset.neutralWhite.color

        clear.image.image = Asset.chatListDeleteSwipe.image
        clear.title.text = Localized.Chat.SheetMenu.clear

        details.tintColor = Asset.neutralDark.color
        details.image.image = Asset.searchUsername.image
        details.title.text = Localized.Chat.SheetMenu.details

        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.addArrangedSubview(clear)
        stack.addArrangedSubview(details)
        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    required init?(coder: NSCoder) { nil }
}
