import UIKit
import Shared

final class SearchContainerView: UIView {
    let scrollView = UIScrollView()
    let segmentedControl = SearchSegmentedControl()

    init() {
        super.init(frame: .zero)

        backgroundColor = Asset.neutralWhite.color
        addSubview(segmentedControl)
        addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(60)
        }
    }

    required init?(coder: NSCoder) { nil }
}
