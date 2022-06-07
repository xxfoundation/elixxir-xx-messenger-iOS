import UIKit
import Models
import Shared
import DrawerFeature
import Combine
import DependencyInjection

public final class RestoreController: UIViewController {
    @Dependency private var coordinator: RestoreCoordinating

    lazy private var screenView = RestoreView()

    private let viewModel: RestoreViewModel
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

    public init(_ ndf: String, _ settings: RestoreSettings) {
        viewModel = .init(ndf: ndf, settings: settings)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func loadView() {
        view = screenView
        presentWarning()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let title = UILabel()
        title.text = Localized.AccountRestore.header
        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back, title])
        )
    }

    private func setupBindings() {
        viewModel.step
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [unowned self] in
                screenView.updateFor(step: $0)

                if $0 == .wrongPass {
                    coordinator.toPassphrase(from: self) { pass in
                        self.viewModel.retryWith(passphrase: pass)
                    }

                    return
                }

                if $0 == .done {
                    coordinator.toSuccess(from: self)
                }
            }.store(in: &cancellables)

        screenView.backButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapBack() }
            .store(in: &cancellables)

        screenView.cancelButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapBack() }
            .store(in: &cancellables)

        screenView.restoreButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                coordinator.toPassphrase(from: self) { passphrase in
                    self.viewModel.didTapRestore(passphrase: passphrase)
                }
            }.store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension RestoreController {
    private func presentWarning() {
        let actionButton = DrawerCapsuleButton(model: .init(
            title: Localized.AccountRestore.Warning.action,
            style: .brandColored
        ))

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.AccountRestore.Warning.title,
                color: Asset.neutralActive.color,
                alignment: .left,
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
