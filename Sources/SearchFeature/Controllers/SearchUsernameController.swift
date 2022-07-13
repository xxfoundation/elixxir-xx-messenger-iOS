import UIKit
import Shared
import Combine
import DrawerFeature
import DependencyInjection

final class SearchUsernameController: UIViewController {
    @Dependency private var coordinator: SearchCoordinating

    lazy private var screenView = SearchUsernameView()

    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    private func setupBindings() {
        screenView.placeholderView
            .infoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in presentSearchDisclaimer() }
            .store(in: &cancellables)
    }

    private func presentSearchDisclaimer() {
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .seeThrough,
            title: Localized.Ud.Placeholder.Drawer.action
        )

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.Ud.Placeholder.Drawer.title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            DrawerLinkText(
                text: Localized.Ud.Placeholder.Drawer.subtitle,
                urlString: "https://links.xx.network/adrp",
                spacingAfter: 37
            ),
            DrawerStack(views: [
                actionButton,
                FlexibleSpace()
            ])
        ])

        actionButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                }
            }.store(in: &self.drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }
}
