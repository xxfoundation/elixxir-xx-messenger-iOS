import UIKit
import Shared
import SnapKit

final class RequestsSegmentedControl: UIView {
    enum Filter {
        case received
        case sent
        case failed
    }

    // MARK: UI

    let track = UIView()
    let trackIndicator = UIView()
    var leftConstraint: Constraint?
    let received = UIButton()
    let sent = UIButton()
    let failed = UIButton()
    let stack = UIStackView()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Public

    func didChooseFilter(_ filter: Filter) {
        switch filter {
        case .received:
            sent.setTitleColor(Asset.neutralWeak.color, for: .normal)
            failed.setTitleColor(Asset.neutralWeak.color, for: .normal)
            received.setTitleColor(Asset.brandPrimary.color, for: .normal)

            sent.titleLabel?.font = Fonts.Mulish.regular.font(size: 14.0)
            failed.titleLabel?.font = Fonts.Mulish.regular.font(size: 14.0)
            received.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 14.0)

        case .sent:
            sent.setTitleColor(Asset.brandPrimary.color, for: .normal)
            failed.setTitleColor(Asset.neutralWeak.color, for: .normal)
            received.setTitleColor(Asset.neutralWeak.color, for: .normal)

            sent.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 14.0)
            failed.titleLabel?.font = Fonts.Mulish.regular.font(size: 14.0)
            received.titleLabel?.font = Fonts.Mulish.regular.font(size: 14.0)

        case .failed:
            sent.setTitleColor(Asset.neutralWeak.color, for: .normal)
            failed.setTitleColor(Asset.brandPrimary.color, for: .normal)
            received.setTitleColor(Asset.neutralWeak.color, for: .normal)

            sent.titleLabel?.font = Fonts.Mulish.regular.font(size: 14.0)
            failed.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 14.0)
            received.titleLabel?.font = Fonts.Mulish.regular.font(size: 14.0)
        }
    }

    func updateLeftConstraint(_ percentage: CGFloat) {
        leftConstraint?.update(offset: percentage * (bounds.width / 3))
    }

    // MARK: Private

    private func setup() {
        sent.setTitle(Localized.Requests.Sent.title, for: .normal)
        failed.setTitle(Localized.Requests.Failed.title, for: .normal)
        received.setTitle(Localized.Requests.Received.title, for: .normal)

        sent.setTitleColor(Asset.neutralWeak.color, for: .normal)
        failed.setTitleColor(Asset.neutralWeak.color, for: .normal)
        received.setTitleColor(Asset.brandPrimary.color, for: .normal)

        sent.titleLabel?.font = Fonts.Mulish.regular.font(size: 14.0)
        failed.titleLabel?.font = Fonts.Mulish.regular.font(size: 14.0)
        received.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 14.0)

        track.backgroundColor = Asset.neutralLine.color
        trackIndicator.backgroundColor = Asset.brandPrimary.color

        stack.addArrangedSubview(received)
        stack.addArrangedSubview(sent)
        stack.addArrangedSubview(failed)

        stack.distribution = .fillEqually
        stack.backgroundColor = Asset.neutralWhite.color

        addSubview(stack)
        addSubview(track)
        track.addSubview(trackIndicator)

        setupConstraints()

        sent.accessibilityIdentifier = Localized.Accessibility.Requests.Sent.tab
        failed.accessibilityIdentifier = Localized.Accessibility.Requests.Failed.tab
        received.accessibilityIdentifier = Localized.Accessibility.Requests.Received.tab
    }

    private func setupConstraints() {
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        track.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        trackIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-1)
            leftConstraint = make.left.equalToSuperview().constraint
            make.bottom.equalToSuperview()
            make.width.equalTo(track).multipliedBy(0.3)
        }
    }
}
