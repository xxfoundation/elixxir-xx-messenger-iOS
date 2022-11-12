import UIKit
import Shared
import Combine
import XXNavigation
import DI

public final class SettingsAdvancedController: UIViewController {
  @Dependency var navigator: Navigator

  private lazy var screenView = SettingsAdvancedView()

  private var cancellables = Set<AnyCancellable>()
  private let viewModel = SettingsAdvancedViewModel()

  public override func loadView() {
    view = screenView
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
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
    let title = UILabel()
    title.text = Localized.Settings.Advanced.title
    title.textColor = Asset.neutralActive.color
    title.font = Fonts.Mulish.semiBold.font(size: 18.0)

    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: title)
    navigationItem.leftItemsSupplementBackButton = true
  }

  private func setupBindings() {
    screenView
      .downloadLogsButton
      .publisher(for: .touchUpInside)
      .sink { [weak viewModel] in
        viewModel?.didTapDownloadLogs()
      }.store(in: &cancellables)

    screenView
      .logRecordingSwitcher
      .switcherView
      .publisher(for: .valueChanged)
      .sink { [weak viewModel] in
        viewModel?.didToggleRecordLogs()
      }.store(in: &cancellables)

    screenView
      .showUsernamesSwitcher
      .switcherView
      .publisher(for: .valueChanged)
      .sink { [weak viewModel] in
        viewModel?.didToggleShowUsernames()
      }.store(in: &cancellables)

    screenView
      .crashReportingSwitcher
      .switcherView
      .publisher(for: .valueChanged)
      .sink { [weak viewModel] in
        viewModel?.didToggleCrashReporting()
      }.store(in: &cancellables)

    screenView
      .reportingSwitcher
      .switcherView
      .publisher(for: .valueChanged)
      .compactMap { [weak screenView] _ in
        screenView?.reportingSwitcher.switcherView.isOn
      }.sink { [weak viewModel] isOn in
        viewModel?.didSetReporting(enabled: isOn)
      }.store(in: &cancellables)

    viewModel
      .sharePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentActivitySheet(items: [$0]))
      }.store(in: &cancellables)

    viewModel
      .state
      .removeDuplicates()
      .map(\.isReportingOptional)
      .sink { [unowned self] in
        screenView.reportingSwitcher.isHidden = !$0
      }.store(in: &cancellables)

    viewModel
      .state
      .removeDuplicates()
      .sink { [unowned self] state in
        screenView.logRecordingSwitcher.switcherView.setOn(state.isRecordingLogs, animated: true)
        screenView.crashReportingSwitcher.switcherView.setOn(state.isCrashReporting, animated: true)
        screenView.showUsernamesSwitcher.switcherView.setOn(state.isShowingUsernames, animated: true)
        screenView.reportingSwitcher.switcherView.setOn(state.isReportingEnabled, animated: true)
      }.store(in: &cancellables)
  }
}
