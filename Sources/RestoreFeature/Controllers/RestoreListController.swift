import HUD
import Popup
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
    private var popupCancellables = Set<AnyCancellable>()

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
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .brandColored,
            title: Localized.Restore.Warning.action
        )

        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.Restore.Warning.title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            PopupLabelAttributed(
                text: Localized.Restore.Warning.subtitle,
                spacingAfter: 37
            ),
            PopupStackView(views: [actionButton])
        ])

        actionButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                popup.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.popupCancellables.removeAll()
                }
            }.store(in: &popupCancellables)

        coordinator.toPopup(popup, from: self)
    }
}
