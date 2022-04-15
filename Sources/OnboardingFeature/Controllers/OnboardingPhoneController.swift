import HUD
import Popup
import Theme
import UIKit
import Shared
import Combine
import DependencyInjection
import ScrollViewController

public final class OnboardingPhoneController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: OnboardingCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = OnboardingPhoneView()
    lazy private var scrollViewController = ScrollViewController()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = OnboardingPhoneViewModel()
    private var popupCancellables = Set<AnyCancellable>()

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar.customize(translucent: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = " "

        setupScrollView()
        setupBindings()

        screenView.didTapInfo = { [weak self] in
            self?.presentInfo(
                title: Localized.Onboarding.Phone.Info.title,
                subtitle: Localized.Onboarding.Phone.Info.subtitle,
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
        viewModel.hud
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        screenView.inputField.textPublisher
            .sink { [unowned self] in viewModel.didInput($0) }
            .store(in: &cancellables)

        screenView.inputField.returnPublisher
            .sink { [unowned self] in screenView.inputField.endEditing(true) }
            .store(in: &cancellables)

        viewModel.state.map(\.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.update(status: $0) }
            .store(in: &cancellables)

        screenView.nextButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapNext() }
            .store(in: &cancellables)

        screenView.skipButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in coordinator.toChats(from: self) }
            .store(in: &cancellables)

        screenView.inputField.codePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                coordinator.toCountries(from: self) { viewModel.didChooseCountry($0) }
            }.store(in: &cancellables)

        viewModel.state.map(\.confirmation)
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [unowned self] in
                viewModel.clearUp()
                coordinator.toPhoneConfirmation(with: $0, from: self) { controller in
                    let successModel = OnboardingSuccessModel(
                        title: Localized.Onboarding.Success.Phone.title,
                        subtitle: nil,
                        nextController: coordinator.toChats(from:)
                    )

                    coordinator.toSuccess(with: successModel, from: controller)
                }
            }.store(in: &cancellables)

        viewModel.state.map(\.country)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                screenView.inputField.set(prefix: $0.prefixWithFlag)
                screenView.inputField.update(placeholder: $0.example)
            }.store(in: &cancellables)
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
