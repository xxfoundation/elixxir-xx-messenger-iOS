import HUD
import Popup
import Theme
import UIKit
import Shared
import Combine
import DependencyInjection
import ScrollViewController

final class OnboardingEmailController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: OnboardingCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = OnboardingEmailView()
    lazy private var scrollViewController = ScrollViewController()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = OnboardingEmailViewModel()
    private var popupCancellables = Set<AnyCancellable>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar.customize(translucent: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = " "

        setupScrollView()
        setupBindings()

        screenView.didTapInfo = { [weak self] in
            self?.presentInfo(
                title: Localized.Onboarding.Email.Info.title,
                subtitle: Localized.Onboarding.Email.Info.subtitle,
                urlString: "https://links.xx.network/ud"
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
        viewModel.hud.receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        screenView.inputField.textPublisher
            .sink { [unowned self] in viewModel.didInput($0) }
            .store(in: &cancellables)

        screenView.inputField.returnPublisher
            .sink { [unowned self] in screenView.inputField.endEditing(true) }
            .store(in: &cancellables)

        viewModel.state
            .map(\.confirmation)
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [unowned self] in
                viewModel.clearUp()
                coordinator.toEmailConfirmation(with: $0, from: self) { controller in
                    coordinator.toSuccess(isEmail: true, from: controller)
                }
            }.store(in: &cancellables)

        viewModel.state
            .map(\.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.update(status: $0) }
            .store(in: &cancellables)

        screenView.nextButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapNext() }
            .store(in: &cancellables)

        screenView.skipButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in coordinator.toPhone(from: self) }
            .store(in: &cancellables)
    }

    private func presentInfo(
        title: String,
        subtitle: String,
        urlString: String = ""
    ) {
        let actionButton = CapsuleButton()
        actionButton.set(style: .seeThrough, title: Localized.Settings.InfoPopUp.action)

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
