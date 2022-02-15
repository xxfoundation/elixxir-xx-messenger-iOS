import Theme
import UIKit
import Shared
import Combine
import DependencyInjection

public enum MenuItem {
    case scan
    case contacts
    case requests
    case profile
    case settings
    case dashboard
    case join
}

public protocol MenuDelegate: AnyObject {
    func didSelect(item: MenuItem)
}

public final class MenuController: UIViewController {
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = MenuView()

    weak var delegate: MenuDelegate?
    private let viewModel = MenuViewModel()
    private var cancellables = Set<AnyCancellable>()

    public init(_ delegate: MenuDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func loadView() {
        view = screenView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        screenView.headerView.set(
            username: viewModel.username,
            image: viewModel.avatar
        )

        screenView.xxdkVersionLabel.text = "XXDK \(viewModel.xxdk)"
        screenView.buildLabel.text = Localized.Menu.build(viewModel.build)
        screenView.versionLabel.text = Localized.Menu.version(viewModel.version)
        setupBindings()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.lightContent)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        statusBarController.style.send(.darkContent)
    }

    private func setupBindings() {
        screenView.headerView.scanButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak self] in
                    self?.delegate?.didSelect(item: .scan)
                }
            }.store(in: &cancellables)

        screenView.profileButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak self] in
                    self?.delegate?.didSelect(item: .profile)
                }
            }.store(in: &cancellables)

        screenView.scanButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak self] in
                    self?.delegate?.didSelect(item: .scan)
                }
            }.store(in: &cancellables)

        screenView.chatsButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in dismiss(animated: true) }
            .store(in: &cancellables)

        screenView.contactsButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak self] in
                    self?.delegate?.didSelect(item: .contacts)
                }
            }.store(in: &cancellables)

        screenView.settingsButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak self] in
                    self?.delegate?.didSelect(item: .settings)
                }
            }.store(in: &cancellables)

        screenView.dashboardButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak self] in
                    self?.delegate?.didSelect(item: .dashboard)
                }
            }.store(in: &cancellables)

        screenView.joinButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak self] in
                    self?.delegate?.didSelect(item: .join)
                }
            }.store(in: &cancellables)

        screenView.requestsButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak self] in
                    self?.delegate?.didSelect(item: .requests)
                }
            }.store(in: &cancellables)

        viewModel.requestCount
            .receive(on: DispatchQueue.main)
            .sink { [weak screenView] in screenView?.requestsButton.updateNotification($0) }
            .store(in: &cancellables)
    }
}
