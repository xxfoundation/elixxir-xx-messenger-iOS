import UIKit
import Shared
import Combine
import DependencyInjection

final class AdvancedController: UIViewController {
    @Dependency private var coordinator: SettingsCoordinating

    lazy private var screenView = AdvancedView()

    private let viewModel = AdvancedViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func loadView() {
        view = screenView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .customize(backgroundColor: Asset.neutralWhite.color)
    }

    override func viewDidLoad() {
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
        viewModel.sharePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toActivityController(with: [$0], from: self) }
            .store(in: &cancellables)

        screenView.downloadLogs
            .publisher(for: .touchUpInside)
            .sink { [weak viewModel] in viewModel?.didTapDownloadLogs() }
            .store(in: &cancellables)

        screenView.logs.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleRecordLogs() }
            .store(in: &cancellables)

        screenView.crashes.switcherView
            .publisher(for: .valueChanged)
            .sink { [weak viewModel] in viewModel?.didToggleCrashReporting() }
            .store(in: &cancellables)

        viewModel.state
            .removeDuplicates()
            .sink { [unowned self] state in
                screenView.logs.switcherView.setOn(state.isRecordingLogs, animated: true)
                screenView.crashes.switcherView.setOn(state.isCrashReporting, animated: true)
            }.store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
