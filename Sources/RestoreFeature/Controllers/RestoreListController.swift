import HUD
import UIKit
import Shared
import Combine
import DrawerFeature
import DependencyInjection

public final class RestoreListController: UIViewController {
    @Dependency private var hud: HUD
    @Dependency private var coordinator: RestoreCoordinating

    lazy private var screenView = RestoreListView()

    private let viewModel = RestoreListViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
        presentWarning()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.customize(translucent: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.hudPublisher
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        viewModel.backupPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                coordinator.toRestore(with: $0, from: self)
            }.store(in: &cancellables)

        screenView.cancelButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapBack() }
            .store(in: &cancellables)

        screenView.driveButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                viewModel.didTapCloud(.drive, from: self)
            }.store(in: &cancellables)

        screenView.icloudButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                viewModel.didTapCloud(.icloud, from: self)
            }.store(in: &cancellables)

        screenView.dropboxButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                viewModel.didTapCloud(.dropbox, from: self)
            }.store(in: &cancellables)

        screenView.sftpButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                viewModel.didTapCloud(.sftp, from: self)
            }.store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension RestoreListController {
    private func presentWarning() {
        let actionButton = DrawerCapsuleButton(model: .init(
            title: Localized.AccountRestore.Warning.action,
            style: .brandColored
        ))

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.AccountRestore.Warning.title,
                spacingAfter: 19
            ),
            DrawerText(
                text: Localized.AccountRestore.Warning.subtitle,
                spacingAfter: 37
            ),
            actionButton
        ])

        actionButton.action
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }
}
