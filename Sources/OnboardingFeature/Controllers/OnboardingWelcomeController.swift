import Popup
import Theme
import UIKit
import Shared
import Combine
import Defaults
import DependencyInjection

public final class OnboardingWelcomeController: UIViewController {
    @KeyObject(.username, defaultValue: "") var username: String
    @Dependency private var coordinator: OnboardingCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = OnboardingWelcomeView()

    private var cancellables = Set<AnyCancellable>()
    private var popupCancellables = Set<AnyCancellable>()

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
            title: Localized.Settings.InfoPopUp.action
        )

        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            PopupLinkText(
                text: subtitle,
                urlString: urlString,
                spacingAfter: 37
            ),
            PopupStackView(views: [actionButton, FlexibleSpace()])
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
