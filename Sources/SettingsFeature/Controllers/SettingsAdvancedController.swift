import UIKit
import Shared
import Combine
import DependencyInjection

public final class SettingsAdvancedController: UIViewController {
    @Dependency private var coordinator: SettingsCoordinating

    lazy private var screenView = SettingsAdvancedView()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = SettingsAdvancedViewModel()

    public override func loadView() {
        view = screenView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .customize(backgroundColor: Asset.neutralWhite.color)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()

        viewModel.loadCachedSettings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let title = UILabel()
        title.text = Localized.Settings.Advanced.title
        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back, title])
        )
    }

    private func setupBindings() {
        screenView.downloadLogsButton
            .publisher(for: .touchUpInside)
            .sink { [weak viewModel] in viewModel?.didTapDownloadLogs() }
            .store(in: &cancellables)

        screenView.logRecordingSwitcher.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleRecordLogs() }
            .store(in: &cancellables)

        screenView.showUsernamesSwitcher.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleShowUsernames() }
            .store(in: &cancellables)

        screenView.crashReportingSwitcher.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleCrashReporting() }
            .store(in: &cancellables)

        viewModel.sharePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toActivityController(with: [$0], from: self) }
            .store(in: &cancellables)

        viewModel.state
            .removeDuplicates()
            .sink { [unowned self] state in
                screenView.logRecordingSwitcher.switcherView.setOn(state.isRecordingLogs, animated: true)
                screenView.crashReportingSwitcher.switcherView.setOn(state.isCrashReporting, animated: true)
                screenView.showUsernamesSwitcher.switcherView.setOn(state.isShowingUsernames, animated: true)
            }.store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
