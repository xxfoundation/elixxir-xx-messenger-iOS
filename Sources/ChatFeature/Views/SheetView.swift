import UIKit
import Shared

final class SheetView: UIView {
    let stackView = UIStackView()
    let clearButton = SheetButton()
    let reportButton = SheetButton()
    let detailsButton = SheetButton()

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 40
        layer.masksToBounds = true
        backgroundColor = Asset.neutralWhite.color

        clearButton.image.image = Asset.chatListDeleteSwipe.image
        clearButton.title.text = Localized.Chat.SheetMenu.clear

        detailsButton.tintColor = Asset.neutralDark.color
        detailsButton.image.image = Asset.searchUsername.image
        detailsButton.title.text = Localized.Chat.SheetMenu.details

        reportButton.tintColor = Asset.accentDanger.color
        reportButton.image.image = Asset.searchUsername.image
        reportButton.title.text = Localized.Chat.SheetMenu.report

        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(clearButton)
        stackView.addArrangedSubview(detailsButton)
        stackView.addArrangedSubview(reportButton)
        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    required init?(coder: NSCoder) { nil }
}
