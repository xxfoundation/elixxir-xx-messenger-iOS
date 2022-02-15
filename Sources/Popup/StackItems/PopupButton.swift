import UIKit
import Shared
import Combine

public final class PopupButton: PopupStackItem {
    // MARK: Properties

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

    // MARK: Lifecycle

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

    // MARK: Builder

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
