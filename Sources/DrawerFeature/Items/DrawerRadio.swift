import UIKit
import Shared
import Combine

public final class DrawerRadio: DrawerItem {
    private let title: String
    private let isSelected: Bool
    private var cancellables = Set<AnyCancellable>()
    private let actionSubject = PassthroughSubject<Void, Never>()

    public var spacingAfter: CGFloat? = 0
    public var action: AnyPublisher<Void, Never> { actionSubject.eraseToAnyPublisher() }

    public init(
        title: String,
        isSelected: Bool,
        spacingAfter: CGFloat = 10
    ) {
        self.title = title
        self.isSelected = isSelected
        self.spacingAfter = spacingAfter
    }

    public func makeView() -> UIView {
        cancellables.removeAll()

        let radioView = UIView()
        let titleLabel = UILabel()
        let radioInnerView = UIView()

        let view = UIControl()
        view.addSubview(titleLabel)
        view.addSubview(radioView)
        radioView.addSubview(radioInnerView)

        titleLabel.text = title
        titleLabel.textColor = Asset.neutralDark.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        radioView.layer.cornerRadius = 11.0
        radioInnerView.layer.cornerRadius = 3
        radioView.isUserInteractionEnabled = false

        if isSelected {
            radioView.layer.borderWidth = 0.0
            radioView.backgroundColor = Asset.brandLight.color
            radioView.layer.borderColor = Asset.brandLight.color.cgColor
            radioInnerView.backgroundColor = Asset.neutralWhite.color
        } else {
            radioView.layer.borderWidth = 1.0
            radioView.backgroundColor = Asset.neutralSecondary.color
            radioView.layer.borderColor = Asset.neutralLine.color.cgColor
            radioInnerView.backgroundColor = .clear
        }

        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(42)
            $0.centerY.equalToSuperview()
        }

        radioView.snp.makeConstraints {
            $0.right.equalTo(titleLabel.snp.left).offset(-12)
            $0.width.height.equalTo(20)
            $0.centerY.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-5)
        }

        radioInnerView.snp.makeConstraints {
            $0.width.height.equalTo(6)
            $0.center.equalToSuperview()
        }

        view.publisher(for: .touchUpInside)
            .sink { [weak self] in self?.actionSubject.send() }
            .store(in: &cancellables)

        return view
    }
}
