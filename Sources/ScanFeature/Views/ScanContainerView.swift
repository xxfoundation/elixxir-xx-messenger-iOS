import UIKit
import Shared

final class ScanContainerView: UIView {
    let scrollView = UIScrollView()
    let scanScreen = ScanController()
    let segmentedControl = SegmentedControl()
    let displayScreen = ScanDisplayController()

    init() {
        super.init(frame: .zero)

        backgroundColor = Asset.neutralActive.color
        addSubview(segmentedControl)
        addSubview(scrollView)

        scrollView.addSubview(scanScreen.view)
        scrollView.addSubview(displayScreen.view)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        displayScreen.view.snp.makeConstraints { $0.top.bottom.width.equalTo(scanScreen.view) }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }

        scanScreen.view.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.bottom.width.equalTo(self)
            make.right.equalTo(displayScreen.view.snp.left)
            make.left.equalToSuperview()
        }
    }
}
