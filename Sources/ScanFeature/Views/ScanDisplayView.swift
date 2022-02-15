import UIKit
import Shared

final class ScanDisplayView: UIView {
    let qrView = UIView()
    let qrImage = UIImageView()
    let shareView = ScanDisplayShareView()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralDark.color

        qrView.backgroundColor = Asset.neutralWhite.color
        qrView.layer.cornerRadius = 30

        addSubview(qrView)
        qrView.addSubview(qrImage)

        qrView.snp.makeConstraints { make in
            make.width.height.equalTo(207)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
        }

        qrImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.top.equalToSuperview().offset(20)
        }
    }

    required init?(coder: NSCoder) { nil }

    func setupShareView(info: @escaping () -> Void) {
        addSubview(shareView)
        shareView.didTapInfo = info

        shareView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}
