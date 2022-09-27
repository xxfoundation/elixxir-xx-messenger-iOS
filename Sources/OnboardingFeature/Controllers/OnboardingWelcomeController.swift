import Theme
import UIKit
import Shared
import Combine
import Defaults
import DrawerFeature
import DependencyInjection

public final class OnboardingWelcomeController: UIViewController {
    @KeyObject(.username, defaultValue: "") var username: String
    @Dependency private var coordinator: OnboardingCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = OnboardingWelcomeView()

    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar.customize(translucent: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()

        screenView.setupTitle(Localized.Onboarding.Welcome.title(username))

        screenView.didTapInfo = { [weak self] in
            self?.presentInfo(
                title: Localized.Onboarding.Welcome.Info.title,
                subtitle: Localized.Onboarding.Welcome.Info.subtitle,
                urlString: "https://links.xx.network/ud"
            )
        }
    }

    private func setupBindings() {
        screenView.continueButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in coordinator.toEmail(from: self) }
            .store(in: &cancellables)

        screenView.skipButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in coordinator.toChats(from: self) }
            .store(in: &cancellables)
    }

    private func presentInfo(
        title: String,
        subtitle: String,
        urlString: String = ""
    ) {
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
            DrawerLinkText(
                text: subtitle,
                urlString: urlString,
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
