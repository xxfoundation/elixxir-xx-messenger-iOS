import UIKit
import Shared
import AppResources

final class RetrySheetView: UIView {
    // MARK: UI

    let stack = UIStackView()
    let retry = SheetButton()
    let delete = SheetButton()
    let cancel = SheetButton(.destructive)

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        layer.cornerRadius = 15
        layer.masksToBounds = true
        backgroundColor = Asset.neutralWhite.color

        retry.title.text = Localized.Chat.RetrySheet.retry
        delete.title.text = Localized.Chat.RetrySheet.delete
        cancel.title.text = Localized.Chat.RetrySheet.cancel

        retry.image.image = Asset.lens.image
        delete.image.image = Asset.lens.image
        cancel.image.image = Asset.lens.image

        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.addArrangedSubview(retry)
        stack.addArrangedSubview(delete)
        stack.addArrangedSubview(cancel)

        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}
