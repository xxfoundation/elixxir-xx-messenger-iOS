import UIKit
import Combine

public final class SFTPController: UIViewController {
    lazy private var screenView = SFTPView()

    private let viewModel = SFTPViewModel()
    private var cancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
    }

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
