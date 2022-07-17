import HUD
import UIKit
import Combine
import DependencyInjection
import ScrollViewController

public final class SFTPController: UIViewController {
    @Dependency private var hud: HUDType

    lazy private var screenView = SFTPView()
    lazy private var scrollViewController = ScrollViewController()

    private let completion: () -> Void
    private let viewModel = SFTPViewModel()
    private var cancellables = Set<AnyCancellable>()

    public init(_ completion: @escaping () -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupNavigationBar()
        setupBindings()
    }

    private func setupScrollView() {
        scrollViewController.scrollView.backgroundColor = .white

        addChild(scrollViewController)
        view.addSubview(scrollViewController.view)
        scrollViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollViewController.didMove(toParent: self)
        scrollViewController.contentView = screenView
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

        viewModel.authPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in completion() }
            .store(in: &cancellables)

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
