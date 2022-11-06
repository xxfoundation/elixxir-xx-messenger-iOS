import UIKit
import Shared
import XXModels

final class ContactView: UIView {
    let container = UIView()
    let cardComponent = AvatarCardComponent()

    let scannedView = ContactScannedView()
    let successView = ContactSuccessView()
    let receivedView = ContactReceivedView()
    let inProgressView = ContactAlmostView()
    let confirmedView = ContactConfirmedView()

    var didTapInfo: (() -> Void)?
    var didTapSend: (() -> Void)?

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        addSubview(cardComponent)
        addSubview(container)

        cardComponent.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        container.snp.makeConstraints { make in
            make.top.equalTo(cardComponent.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    func set(status: Contact.AuthStatus) {
        let contentView: UIView

        switch status {
        case .stranger:
            contentView = scannedView
        case .verified:
            contentView = receivedView
        case .friend:
            cardComponent.setupButtons(
                info: didTapInfo ?? { print("info") },
                send: didTapSend ?? { print("send") }
            )

            contentView = confirmedView
        default:
            inProgressView.set(status: status)
            contentView = inProgressView
        }

        container.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func updateToSuccess() {
        container.subviews.forEach { $0.removeFromSuperview() }
        container.addSubview(successView)
        successView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func updateTopOffset(_ offset: CGFloat) {
        cardComponent.snp.updateConstraints {
            $0.top.equalToSuperview().offset(offset)
        }
    }

    func updateBottomOffset(_ offset: CGFloat) {
        container.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(offset)
        }
    }
}
