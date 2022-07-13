import HUD
import DrawerFeature
import Shared
import UIKit
import Combine
import DependencyInjection

public final class RestoreListController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: RestoreCoordinating

    lazy private var screenView = RestoreListView()

    private let ndf: String
    private let viewModel = RestoreListViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
        presentWarning()
    }

    public init(_ ndf: String) {
        self.ndf = ndf
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) { nil }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.customize(translucent: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back])
        )
    }

    private func setupBindings() {
        viewModel.hud
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        viewModel.didFetchBackup
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toRestore(using: ndf, with: $0, from: self) }
            .store(in: &cancellables)

        screenView.cancelButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapBack() }
            .store(in: &cancellables)

        screenView.driveButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapCloud(.drive, from: self) }
            .store(in: &cancellables)

        screenView.icloudButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapCloud(.icloud, from: self) }
            .store(in: &cancellables)

        screenView.dropboxButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapCloud(.dropbox, from: self) }
            .store(in: &cancellables)
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