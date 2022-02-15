import UIKit
import Shared

final class RequestsContainerView: UIView {
    // MARK: UI

    let scrollView = UIScrollView()
    let sent = RequestsSentController()
    let failed = RequestsFailedController()
    let received = RequestsReceivedController()
    let segmentedControl = RequestsSegmentedControl()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
        backgroundColor = Asset.neutralActive.color

        addSubview(segmentedControl)
        addSubview(scrollView)

        scrollView.addSubview(sent.view)
        scrollView.addSubview(failed.view)
        scrollView.addSubview(received.view)

        scrollView.addSubview(sent.emptyView)
        scrollView.addSubview(received.emptyView)

        sent.emptyView.snp.makeConstraints { $0.edges.equalTo(sent.view) }
        received.emptyView.snp.makeConstraints { $0.edges.equalTo(received.view) }

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(50)
        }

        received.view.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalTo(sent.view.snp.left)
            make.bottom.equalTo(self)
            make.width.equalTo(self)
        }

        sent.view.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.right.equalTo(failed.view.snp.left)
            make.bottom.equalTo(self)
            make.width.equalTo(self)
        }

        failed.view.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.right.equalToSuperview()
            make.bottom.equalTo(self)
            make.width.equalTo(self)
        }
    }
}
