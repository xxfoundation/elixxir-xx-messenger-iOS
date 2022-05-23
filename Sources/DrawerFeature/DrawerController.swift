import UIKit

public final class DrawerController: UIViewController {
    lazy private var screenView = DrawerView()

    private let content: [DrawerItem]

    public init(with content: [DrawerItem]) {
        self.content = content
        super.init(nibName: nil, bundle: nil)

        let views = content.map { $0.makeView() }
        views.forEach { screenView.stackView.addArrangedSubview($0) }

        content.enumerated().forEach { item in
            guard let spacing = item.element.spacingAfter else { return }
            screenView.stackView.setCustomSpacing(spacing, after: views[item.offset])
        }
    }

    required init?(coder: NSCoder) { nil }

    public override func loadView() {
        view = screenView
    }
}
