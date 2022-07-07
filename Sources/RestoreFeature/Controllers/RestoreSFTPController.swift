import HUD
import UIKit
import Combine
import DependencyInjection

public final class RestoreSFTPController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: RestoreCoordinating

    lazy private var screenView = RestoreSFTPView()

    private let ndf: String
    private let viewModel = RestoreSFTPViewModel()
    private var cancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
    }

    public init(_ ndf: String) {
        self.ndf = ndf
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back])
        )
    }

    private func setupBindings() {
        viewModel.hudPublisher
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        viewModel.backupPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                coordinator.toRestoreReplacing(using: ndf, with: $0, from: self)
            }.store(in: &cancellables)

        screenView.hostField
            .textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in viewModel.didEnterHost($0) }
            .store(in: &cancellables)

        screenView.usernameField
            .textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in viewModel.didEnterUsername($0) }
            .store(in: &cancellables)

        screenView.passwordField
            .textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in viewModel.didEnterPassword($0) }
            .store(in: &cancellables)

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map(\.isButtonEnabled)
            .sink { [unowned self] in screenView.loginButton.isEnabled = $0 }
            .store(in: &cancellables)

        screenView.loginButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapLogin() }
            .store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
