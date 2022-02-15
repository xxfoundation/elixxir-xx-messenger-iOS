import UIKit
import Shared
import SnapKit

final class SegmentedControl: UIView {
    let trackView = UIView()
    let trackIndicatorView = UIView()
    var leftConstraint: Constraint?
    let leftButton = SegmentedControlButton()
    let rightButton = SegmentedControlButton()
    let stackView = UIStackView()

    init() {
        super.init(frame: .zero)

        rightButton.icon.image = Asset.scanQr.image
        leftButton.title.text = Localized.Scan.SegmentedControl.left
        rightButton.title.text = Localized.Scan.SegmentedControl.right

        leftButton.title.font = Fonts.Mulish.semiBold.font(size: 14.0)
        rightButton.title.font = Fonts.Mulish.semiBold.font(size: 14.0)

        trackIndicatorView.backgroundColor = Asset.brandPrimary.color

        stackView.spacing = 40
        stackView.addArrangedSubview(leftButton)
        stackView.addArrangedSubview(rightButton)

        addSubview(stackView)
        addSubview(trackView)
        trackView.addSubview(trackIndicatorView)

        stackView.snp.makeConstraints { make in
            make.top.equalTo(trackView.snp.bottom).offset(2)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        trackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(stackView)
            make.right.equalTo(stackView)
            make.height.equalTo(3)
        }

        trackIndicatorView.snp.makeConstraints { make in
            leftConstraint = make.left.equalToSuperview().constraint
            make.top.bottom.equalToSuperview()
            make.width.equalTo(75)
        }
    }

    required init?(coder: NSCoder) { nil }

    func updateLeftConstraint(_ percentage: CGFloat) {
        leftConstraint?.update(offset: percentage * 125)
    }
}
