import UIKit
import Popup
import Models
import Shared
import Combine
import DependencyInjection

final class BackupConfigController: UIViewController {
    @Dependency private var coordinator: BackupCoordinating

    lazy private var screenView = BackupConfigView()

    private let viewModel: BackupConfigViewModel
    private var cancellables = Set<AnyCancellable>()
    private var popupCancellables = Set<AnyCancellable>()

    private var wifiOnly = false
    private var manualBackups = false
    private var serviceName: String = ""

    override func loadView() {
        view = screenView
    }

    init(_ viewModel: BackupConfigViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    private func setupBindings() {
        viewModel.actionState()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.actionView.setState($0) }
            .store(in: &cancellables)

        viewModel.connectedServices()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in decorate(connectedServices: $0) }
            .store(in: &cancellables)

        viewModel.enabledService()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in decorate(enabledService: $0) }
            .store(in: &cancellables)

        viewModel.automatic()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                screenView.frequencyDetailView.subtitleLabel.text = $0 ? "Automatic" : "Manual"
                manualBackups = !$0
            }.store(in: &cancellables)

        viewModel.wifiOnly()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                screenView.infrastructureDetailView.subtitleLabel.text = $0 ? "Wi-Fi Only" : "Wi-Fi and Cellular"
                wifiOnly = $0
            }.store(in: &cancellables)

        viewModel.lastBackup()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                guard let backup = $0 else {
                    screenView.latestBackupDetailView.subtitleLabel.text = "Never"
                    return
                }

                screenView.latestBackupDetailView.subtitleLabel.text = backup.date.backupStyle()
            }.store(in: &cancellables)

        screenView.actionView.backupNowButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapBackupNow() }
            .store(in: &cancellables)

        screenView.frequencyDetailView
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in presentFrequencyPopup(manual: manualBackups) }
            .store(in: &cancellables)

        screenView.infrastructureDetailView
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in presentInfrastructurePopup(wifiOnly: wifiOnly) }
            .store(in: &cancellables)

        screenView.googleDriveButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapService(.drive, self) }
            .store(in: &cancellables)

        screenView.googleDriveButton.switcherView
            .publisher(for: .valueChanged)
            .sink { [unowned self] in viewModel.didToggleService(self, .drive, screenView.googleDriveButton.switcherView.isOn) }
            .store(in: &cancellables)

        screenView.dropboxButton.switcherView
            .publisher(for: .valueChanged)
            .sink { [unowned self] in viewModel.didToggleService(self, .dropbox, screenView.dropboxButton.switcherView.isOn) }
            .store(in: &cancellables)

        screenView.iCloudButton.switcherView
            .publisher(for: .valueChanged)
            .sink { [unowned self] in viewModel.didToggleService(self, .icloud, screenView.iCloudButton.switcherView.isOn) }
            .store(in: &cancellables)

        screenView.dropboxButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapService(.dropbox, self) }
            .store(in: &cancellables)

        screenView.iCloudButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapService(.icloud, self) }
            .store(in: &cancellables)
    }

    private func decorate(enabledService: CloudService?) {
        var button: BackupSwitcherButton?

        switch enabledService {
        case .none:
            break
        case .icloud:
            serviceName = "iCloud"
            button = screenView.iCloudButton

        case .dropbox:
            serviceName = "Dropbox"
            button = screenView.dropboxButton

        case .drive:
            serviceName = "Google Drive"
            button = screenView.googleDriveButton
        }

        screenView.enabledSubtitleLabel.text
        = Localized.Backup.Config.disclaimer(serviceName)
        screenView.frequencyDetailView.titleLabel.text
        = Localized.Backup.Config.frequency(serviceName).uppercased()

        guard let button = button else {
            screenView.iCloudButton.isHidden = false
            screenView.dropboxButton.isHidden = false
            screenView.googleDriveButton.isHidden = false

            screenView.iCloudButton.switcherView.isOn = false
            screenView.dropboxButton.switcherView.isOn = false
            screenView.googleDriveButton.switcherView.isOn = false

            screenView.frequencyDetailView.isHidden = true
            screenView.enabledSubtitleView.isHidden = true
            screenView.latestBackupDetailView.isHidden = true
            screenView.infrastructureDetailView.isHidden = true
            return
        }

        screenView.frequencyDetailView.isHidden = false
        screenView.enabledSubtitleView.isHidden = false
        screenView.latestBackupDetailView.isHidden = false
        screenView.infrastructureDetailView.isHidden = false

        [screenView.iCloudButton, screenView.dropboxButton, screenView.googleDriveButton]
            .forEach {
                $0.isHidden = $0 != button
                $0.switcherView.isOn = $0 == button
            }
    }

    private func decorate(connectedServices: Set<CloudService>) {
        if connectedServices.contains(.icloud) {
            screenView.iCloudButton.showSwitcher(enabled: false)
        } else {
            screenView.iCloudButton.showChevron()
        }

        if connectedServices.contains(.dropbox) {
            screenView.dropboxButton.showSwitcher(enabled: false)
        } else {
            screenView.dropboxButton.showChevron()
        }

        if connectedServices.contains(.drive) {
            screenView.googleDriveButton.showSwitcher(enabled: false)
        } else {
            screenView.googleDriveButton.showChevron()
        }
    }

    private func presentInfrastructurePopup(wifiOnly: Bool) {
        let cancelButton = CapsuleButton()
        cancelButton.setStyle(.seeThrough)
        cancelButton.setTitle(Localized.ChatList.Dashboard.cancel, for: .normal)

        let wifiOnlyButton = PopupRadioButton(title: "Wi-Fi Only", isSelected: wifiOnly)
        let wifiAndCellularButton = PopupRadioButton(title: "Wi-Fi and Cellular", isSelected: !wifiOnly)

        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.extraBold.font(size: 28.0),
                text: Localized.Backup.Config.infrastructure,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 30
            ),
            wifiOnlyButton,
            wifiAndCellularButton,
            PopupEmptyView(height: 20.0),
            PopupStackView(spacing: 20.0, views: [cancelButton])
        ])

        wifiOnlyButton.action
            .sink { [unowned self] in
                viewModel.didChooseWifiOnly(true)

                popup.dismiss(animated: true) { [weak self] in
                    self?.popupCancellables.removeAll()
                }
            }.store(in: &popupCancellables)

        wifiAndCellularButton.action
            .sink { [unowned self] in
                viewModel.didChooseWifiOnly(false)

                popup.dismiss(animated: true) { [weak self] in
                    self?.popupCancellables.removeAll()
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

    private func presentFrequencyPopup(manual: Bool) {
        let cancelButton = CapsuleButton()
        cancelButton.setStyle(.seeThrough)
        cancelButton.setTitle(Localized.ChatList.Dashboard.cancel, for: .normal)

        let manualButton = PopupRadioButton(title: "Manual", isSelected: manual)
        let automaticButton = PopupRadioButton(title: "Automatic", isSelected: !manual)

        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.extraBold.font(size: 28.0),
                text: Localized.Backup.Config.frequency(serviceName),
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 30
            ),
            manualButton,
            automaticButton,
            PopupEmptyView(height: 20.0),
            PopupStackView(spacing: 20.0, views: [cancelButton])
        ])

        manualButton.action
            .sink { [unowned self] in
                viewModel.didChooseAutomatic(false)

                popup.dismiss(animated: true) { [weak self] in
                    self?.popupCancellables.removeAll()
                }
            }.store(in: &popupCancellables)

        automaticButton.action
            .sink { [unowned self] in
                viewModel.didChooseAutomatic(true)

                popup.dismiss(animated: true) { [weak self] in
                    self?.popupCancellables.removeAll()
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
}
