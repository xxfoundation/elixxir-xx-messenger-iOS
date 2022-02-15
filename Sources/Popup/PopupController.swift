import UIKit
import Shared
import Combine
import ScrollViewController

public enum PopupInputType: Equatable {
    case email
    case emailCode
    case emailSuccess(String)
    case phone
    case phoneCode
    case phoneSuccess(String)
    case done
}

public final class Popup: UIViewController {
    lazy private var screenView = PopupView()
    lazy private var containerView = UIView()
    lazy private var scrollViewController = ScrollViewController()

    private let content: [PopupStackItem]

    public init(with content: [PopupStackItem]) {
        self.content = content
        super.init(nibName: nil, bundle: nil)

        let views = content.map { $0.makeView() }

        views.forEach { screenView.stack.addArrangedSubview($0) }

        content.enumerated().forEach { item in
            guard let spacing = item.element.spacingAfter else { return }
            screenView.stack.setCustomSpacing(spacing, after: views[item.offset])
        }
    }

    public required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()

        scrollViewController.view.backgroundColor = .clear

        addChild(scrollViewController)
        view.addSubview(scrollViewController.view)

        scrollViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollViewController.didMove(toParent: self)
        containerView.addSubview(screenView)

        screenView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(50)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-50)
        }

        scrollViewController.contentView = containerView
    }
}

public final class BottomPopup: UIViewController {
    lazy private var screenView = BottomPopupView()

    private let content: [PopupStackItem]

    public init(with content: [PopupStackItem]) {
        self.content = content
        super.init(nibName: nil, bundle: nil)

        let views = content.map { $0.makeView() }

        views.forEach { screenView.stack.addArrangedSubview($0) }

        content.enumerated().forEach { item in
            guard let spacing = item.element.spacingAfter else { return }
            screenView.stack.setCustomSpacing(spacing, after: views[item.offset])
        }
    }

    required init?(coder: NSCoder) { nil }

    public override func loadView() {
        view = screenView
    }
}

final class BottomPopupView: UIView {
    let stack = UIStackView()

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 40
        backgroundColor = Asset.neutralWhite.color
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        stack.axis = .vertical
        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.bottom.equalToSuperview().offset(-70)
        }
    }

    required init?(coder: NSCoder) { nil }
}
