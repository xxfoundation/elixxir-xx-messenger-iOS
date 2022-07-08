import UIKit
import Shared
import SnapKit

final class ScanSegmentedControl: UIView {
    private let trackHeight = 2.0
    private let numberOfTabs = 2.0
    private let trackView = UIView()
    private let stackView = UIStackView()
    private var leftConstraint: Constraint?
    private let trackIndicatorView = UIView()
    private(set) var leftButton = ScanSegmentedControlButton()
    private(set) var rightButton = ScanSegmentedControlButton()

    init() {
        super.init(frame: .zero)

        rightButton.setup(
            title: Localized.Scan.SegmentedControl.right,
            icon: Asset.scanQr.image
        )

        leftButton.setup(
            title: Localized.Scan.SegmentedControl.left,
            icon: Asset.scanScan.image
        )

        trackView.backgroundColor = Asset.neutralLine.color
        trackIndicatorView.backgroundColor = Asset.brandPrimary.color

        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(leftButton)
        stackView.addArrangedSubview(rightButton)

        addSubview(stackView)
        addSubview(trackView)
        trackView.addSubview(trackIndicatorView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(trackView.snp.top)
        }

        trackView.snp.makeConstraints {
            $0.height.equalTo(trackHeight)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        trackIndicatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            leftConstraint = $0.left.equalToSuperview().constraint
            $0.width.equalToSuperview().dividedBy(numberOfTabs)
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    func updateLeftConstraint(_ percentageScrolled: CGFloat) {
        let tabWidth = bounds.width / numberOfTabs
        let leftOffset = percentageScrolled * tabWidth
        leftConstraint?.update(offset: leftOffset)

        leftButton.update(color: .fade(
            from: Asset.brandPrimary.color,
            to: Asset.neutralLine.color,
            pcent: percentageScrolled
        ))

        rightButton.update(color: .fade(
            from: Asset.brandPrimary.color,
            to: Asset.neutralLine.color,
            pcent: 1 - percentageScrolled
        ))
    }
}
