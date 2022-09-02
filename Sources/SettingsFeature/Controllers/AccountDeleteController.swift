import HUD
import UIKit
import DrawerFeature
import Shared
import Combine
import Defaults
import ScrollViewController
import DependencyInjection

public final class AccountDeleteController: UIViewController {
    @KeyObject(.username, defaultValue: "") var username: String

    @Dependency private var hud: HUD
    @Dependency private var coordinator: SettingsCoordinating

    lazy private var screenView = AccountDeleteView()
    lazy private var scrollViewController = ScrollViewController()

    private let viewModel = AccountDeleteViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .customize(backgroundColor: Asset.neutralWhite.color)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupBindings()

        screenView.update(username: username)

        screenView.setInfoClosure { [weak self] in
            self?.presentInfo(
                title: Localized.Settings.Delete.Info.title,
                subtitle: Localized.Settings.Delete.Info.subtitle
            )
        }
    }

    private func setupScrollView() {
        addChild(scrollViewController)
        view.addSubview(scrollViewController.view)
        scrollViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollViewController.didMove(toParent: self)
        scrollViewController.contentView = screenView
        scrollViewController.scrollView.backgroundColor = Asset.neutralWhite.color
    }

    private func setupBindings() {
        viewModel.hudPublisher
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        screenView.cancelButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in dismiss(animated: true) }
            .store(in: &cancellables)

        screenView.inputField.textPublisher
            .sink { [unowned self] in screenView.update(status: $0 == username ? .valid("") : .invalid("")) }
            .store(in: &cancellables)

        screenView.confirmButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in
                DispatchQueue.global().async { [weak self] in
                    self?.viewModel.didTapDelete()
                }
            }.store(in: &cancellables)

        screenView.cancelButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in navigationController?.popViewController(animated: true) }
            .store(in: &cancellables)
    }

    private func presentInfo(title: String, subtitle: String) {
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .seeThrough,
            title: Localized.Settings.InfoDrawer.action
        )

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            DrawerText(
                font: Fonts.Mulish.regular.font(size: 16.0),
                text: subtitle,
                color: Asset.neutralBody.color,
                alignment: .left,
                lineHeightMultiple: 1.1,
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
            }.store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }
}
