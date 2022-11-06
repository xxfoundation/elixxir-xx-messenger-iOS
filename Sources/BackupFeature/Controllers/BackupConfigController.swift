import UIKit
import Shared
import Combine
import CloudFiles
import DrawerFeature
import DependencyInjection

final class BackupConfigController: UIViewController {
    @Dependency private var coordinator: BackupCoordinating

    private lazy var screenView = BackupConfigView()

    private let viewModel: BackupConfigViewModel
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

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

                screenView.latestBackupDetailView.subtitleLabel.text = backup.lastModified.backupStyle()
            }.store(in: &cancellables)

        screenView.actionView.backupNowButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapBackupNow() }
            .store(in: &cancellables)

        screenView.frequencyDetailView
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in presentFrequencyDrawer(manual: manualBackups) }
            .store(in: &cancellables)

        screenView.infrastructureDetailView
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in presentInfrastructureDrawer(wifiOnly: wifiOnly) }
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

        screenView.sftpButton.switcherView
            .publisher(for: .valueChanged)
            .sink { [unowned self] in viewModel.didToggleService(self, .sftp, screenView.sftpButton.switcherView.isOn) }
            .store(in: &cancellables)

        screenView.iCloudButton.switcherView
            .publisher(for: .valueChanged)
            .sink { [unowned self] in viewModel.didToggleService(self, .icloud, screenView.iCloudButton.switcherView.isOn) }
            .store(in: &cancellables)

        screenView.dropboxButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapService(.dropbox, self) }
            .store(in: &cancellables)

        screenView.sftpButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapService(.sftp, self) }
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
            serviceName = Localized.Backup.iCloud
            button = screenView.iCloudButton
        case .dropbox:
            serviceName = Localized.Backup.dropbox
            button = screenView.dropboxButton
        case .drive:
            serviceName = Localized.Backup.googleDrive
            button = screenView.googleDriveButton
        case .sftp:
            serviceName = Localized.Backup.sftp
            button = screenView.sftpButton
        }

        screenView.enabledSubtitleLabel.text
        = Localized.Backup.Config.disclaimer(serviceName)
        screenView.frequencyDetailView.titleLabel.text
        = Localized.Backup.Config.frequency(serviceName).uppercased()

        guard let button = button else {
            screenView.sftpButton.isHidden = false
            screenView.iCloudButton.isHidden = false
            screenView.dropboxButton.isHidden = false
            screenView.googleDriveButton.isHidden = false

            screenView.sftpButton.switcherView.isOn = false
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

        [screenView.iCloudButton,
         screenView.dropboxButton,
         screenView.googleDriveButton,
         screenView.sftpButton].forEach {
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

        if connectedServices.contains(.sftp) {
            screenView.sftpButton.showSwitcher(enabled: false)
        } else {
            screenView.sftpButton.showChevron()
        }
    }

    private func presentInfrastructureDrawer(wifiOnly: Bool) {
        let cancelButton = DrawerCapsuleButton(model: .init(
            title: Localized.ChatList.Dashboard.cancel,
            style: .seeThrough
        ))

        let wifiOnlyButton = DrawerRadio(
            title: "Wi-Fi Only",
            isSelected: wifiOnly
        )

        let wifiAndCellularButton = DrawerRadio(
            title: "Wi-Fi and Cellular",
            isSelected: !wifiOnly,
            spacingAfter: 40
        )

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.extraBold.font(size: 28.0),
                text: Localized.Backup.Config.infrastructure,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 30
            ),
            wifiOnlyButton,
            wifiAndCellularButton,
            cancelButton
        ])

        wifiOnlyButton.action
            .sink { [unowned self] in
                viewModel.didChooseWifiOnly(true)

                drawer.dismiss(animated: true) { [weak self] in
                    self?.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        wifiAndCellularButton.action
            .sink { [unowned self] in
                viewModel.didChooseWifiOnly(false)

                drawer.dismiss(animated: true) { [weak self] in
                    self?.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        cancelButton.action
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    self?.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }

    private func presentFrequencyDrawer(manual: Bool) {
        let cancelButton = DrawerCapsuleButton(model: .init(
            title: Localized.ChatList.Dashboard.cancel,
            style: .seeThrough
        ))

        let manualButton = DrawerRadio(
            title: "Manual",
            isSelected: manual
        )

        let automaticButton = DrawerRadio(
            title: "Automatic",
            isSelected: !manual,
            spacingAfter: 40
        )

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.extraBold.font(size: 28.0),
                text: Localized.Backup.Config.frequency(serviceName),
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 30
            ),
            manualButton,
            automaticButton,
            cancelButton
        ])

        manualButton.action
            .sink { [unowned self] in
                viewModel.didChooseAutomatic(false)

                drawer.dismiss(animated: true) { [weak self] in
                    self?.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        automaticButton.action
            .sink { [unowned self] in
                viewModel.didChooseAutomatic(true)

                drawer.dismiss(animated: true) { [weak self] in
                    self?.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        cancelButton.action
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    self?.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }
}
