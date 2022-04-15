import HUD
import Popup
import UIKit
import Theme
import Shared
import Combine
import DependencyInjection
import ScrollViewController

public final class SettingsController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: SettingsCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var scrollViewController = ScrollViewController()
    lazy private var screenView = SettingsView {
        switch $0 {
        case .icognitoKeyboard:
            self.presentInfo(
                title: Localized.Settings.InfoPopUp.Icognito.title,
                subtitle: Localized.Settings.InfoPopUp.Icognito.subtitle
            )
        case .biometrics:
            self.presentInfo(
                title: Localized.Settings.InfoPopUp.Biometrics.title,
                subtitle: Localized.Settings.InfoPopUp.Biometrics.subtitle
            )
        case .notifications:
            self.presentInfo(
                title: Localized.Settings.InfoPopUp.Notifications.title,
                subtitle: Localized.Settings.InfoPopUp.Notifications.subtitle,
                urlString: "https://links.xx.network/denseids"
            )

        case .dummyTraffic:
            self.presentInfo(
                title: Localized.Settings.InfoPopUp.Traffic.title,
                subtitle: Localized.Settings.InfoPopUp.Traffic.subtitle,
                urlString: "https://links.xx.network/covertraffic"
            )
        }
    }

    private let viewModel = SettingsViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var popupCancellables = Set<AnyCancellable>()

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar
            .customize(backgroundColor: Asset.neutralWhite.color)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupScrollView()
        setupBindings()

        viewModel.loadCachedSettings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let title = UILabel()
        title.text = Localized.Settings.title
        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back, title])
        )
    }

    private func setupScrollView() {
        scrollViewController.view.backgroundColor = Asset.neutralWhite.color

        addChild(scrollViewController)
        view.addSubview(scrollViewController.view)

        scrollViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollViewController.didMove(toParent: self)
        scrollViewController.contentView = screenView
    }

    private func setupBindings() {
        viewModel.hud
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        screenView.inAppNotifications.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleInAppNotifications() }
            .store(in: &cancellables)

        screenView.dummyTraffic.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleDummyTraffic() }
            .store(in: &cancellables)

        screenView.remoteNotifications.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didTogglePushNotifications() }
            .store(in: &cancellables)

        screenView.hideActiveApp.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleHideActiveApps() }
            .store(in: &cancellables)

        screenView.icognitoKeyboard.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleIcognitoKeyboard() }
            .store(in: &cancellables)

        screenView.biometrics.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleBiometrics() }
            .store(in: &cancellables)

        screenView.privacyPolicyButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                presentPopup(
                    title: Localized.Settings.Popup.title(Localized.Settings.privacyPolicy),
                    subtitle: Localized.Settings.Popup.subtitle(Localized.Settings.privacyPolicy),
                    actionTitle: Localized.ChatList.Dashboard.open) {
                        guard let url = URL(string: "https://xx.network/privategrity-corporation-privacy-policy") else { return }
                        UIApplication.shared.open(url, options: [:])
                    }
            }.store(in: &cancellables)

        screenView.disclosuresButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                presentPopup(
                    title: Localized.Settings.Popup.title(Localized.Settings.disclosures),
                    subtitle: Localized.Settings.Popup.subtitle(Localized.Settings.disclosures),
                    actionTitle: Localized.ChatList.Dashboard.open) {
                        guard let url = URL(string: "https://xx.network/privategrity-corporation-terms-of-use") else { return }
                        UIApplication.shared.open(url, options: [:])
                    }
            }.store(in: &cancellables)

        screenView.deleteButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toDelete(from: self) }
            .store(in: &cancellables)

        screenView.accountBackupButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toBackup(from: self) }
            .store(in: &cancellables)

        screenView.advancedButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toAdvanced(from: self) }
            .store(in: &cancellables)

        viewModel.state
            .map(\.isBiometricsPossible)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak screenView] in screenView?.biometrics.switcherView.isEnabled = $0 }
            .store(in: &cancellables)

        viewModel.state
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                screenView.biometrics.switcherView.setOn(state.isBiometricsEnabled, animated: true)
                screenView.hideActiveApp.switcherView.setOn(state.isHideActiveApps, animated: true)
                screenView.icognitoKeyboard.switcherView.setOn(state.isIcognitoKeyboard, animated: true)
                screenView.inAppNotifications.switcherView.setOn(state.isInAppNotification, animated: true)
                screenView.remoteNotifications.switcherView.setOn(state.isPushNotification, animated: true)
                screenView.dummyTraffic.switcherView.setOn(state.isDummyTrafficOn, animated: true)
            }.store(in: &cancellables)
    }

    private func presentPopup(
        title: String,
        subtitle: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) {
        let actionButton = CapsuleButton()
        actionButton.setStyle(.red)
        actionButton.setTitle(actionTitle, for: .normal)

        let cancelButton = CapsuleButton()
        cancelButton.setStyle(.seeThrough)
        cancelButton.setTitle(Localized.ChatList.Dashboard.cancel, for: .normal)

        let popup = BottomPopup(with: [
            PopupImage(image: Asset.popupNegative.image),
            PopupLabel(
                font: Fonts.Mulish.semiBold.font(size: 18.0),
                text: title,
                color: Asset.neutralActive.color
            ),
            PopupLabel(
                font: Fonts.Mulish.semiBold.font(size: 14.0),
                text: subtitle,
                color: Asset.neutralWeak.color,
                lineHeightMultiple: 1.35,
                spacingAfter: 25
            ),
            PopupStackView(
                spacing: 20.0,
                views: [
                    actionButton,
                    cancelButton
                ]
            )
        ])

        actionButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                popup.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.popupCancellables.removeAll()

                    action()
                }
            }.store(in: &popupCancellables)

        cancelButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                popup.dismiss(animated: true) { [weak self] in
                    self?.popupCancellables.removeAll()
                }
            }.store(in: &popupCancellables)

        coordinator.toPopup(popup, from: self)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingsController {
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
