import UIKit
import Shared
import Combine

public final class PopupButton: PopupStackItem {
    let font: UIFont?
    let title: String?
    let color: UIColor?
    let image: UIImage?
    let accessibility: String?
    let pinPoint: UIView.PinningPosition?

    public var spacingAfter: CGFloat? = 10
    private var cancellables = Set<AnyCancellable>()
    private let actionSubject = PassthroughSubject<Void, Never>()

    public var action: AnyPublisher<Void, Never> { actionSubject.eraseToAnyPublisher() }

    public init(
        title: String? = nil,
        font: UIFont? = Fonts.Mulish.regular.font(size: 12.0),
        color: UIColor? = Asset.neutralBody.color,
        image: UIImage? = nil,
        embedding: UIView.PinningPosition? = nil,
        accessibility: String? = nil
    ) {
        self.title = title
        self.font = font
        self.color = color
        self.image = image
        self.pinPoint = embedding
        self.accessibility = accessibility
    }

    public func makeView() -> UIView {
        cancellables.removeAll()

        let view = UIButton()
        view.titleLabel?.font = font
        view.setTitle(title, for: .normal)
        view.setTitleColor(color, for: .normal)
        view.setImage(image, for: .normal)
        view.accessibilityIdentifier = accessibility

        view.publisher(for: .touchUpInside)
            .sink { [weak self] in self?.actionSubject.send() }
            .store(in: &cancellables)

        if let point = pinPoint {
            return view.pinning(at: point)
        } else {
            return view
        }
    }
}

public final class PopupRadioButton: PopupStackItem {
    let radioView = UIView()
    let titleLabel = UILabel()
    let radioInnerView = UIView()

    public var spacingAfter: CGFloat? = 10
    private var cancellables = Set<AnyCancellable>()
    private let actionSubject = PassthroughSubject<Void, Never>()

    public var action: AnyPublisher<Void, Never> { actionSubject.eraseToAnyPublisher() }

    public init(
        title: String,
        isSelected: Bool
    ) {
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
    }

    public func makeView() -> UIView {
        cancellables.removeAll()

        let view = UIControl()
        view.addSubview(titleLabel)
        view.addSubview(radioView)
        radioView.addSubview(radioInnerView)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(42)
            make.centerY.equalToSuperview()
        }

        radioView.snp.makeConstraints { make in
            make.right.equalTo(titleLabel.snp.left).offset(-12)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }

        radioInnerView.snp.makeConstraints { make in
            make.width.height.equalTo(6)
            make.center.equalToSuperview()
        }

        view.publisher(for: .touchUpInside)
            .sink { [weak self] in self?.actionSubject.send() }
            .store(in: &cancellables)

        return view
    }
}
