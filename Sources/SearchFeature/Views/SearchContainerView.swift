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

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(60)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
