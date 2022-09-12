import UIKit
import Shared

final class ScanContainerView: UIView {
    let stackView = UIStackView()
    let leftButton = ScanSegmentedControlButton()
    let rightButton = ScanSegmentedControlButton()

    init() {
        super.init(frame: .zero)

        backgroundColor = Asset.neutralDark.color

        leftButton.set(selected: true)
        rightButton.set(selected: false)
        leftButton.imageView.image = Asset.scanScan.image
        rightButton.imageView.image = Asset.scanQr.image
        leftButton.titleLabel.text = Localized.Scan.SegmentedControl.left
        rightButton.titleLabel.text = Localized.Scan.SegmentedControl.right

        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(leftButton)
        stackView.addArrangedSubview(rightButton)

        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.left.equalToSuperview().offset(50)
            $0.right.equalToSuperview().offset(-50)
            $0.height.equalTo(60)
        }
    }

    required init?(coder: NSCoder) { nil }
}
