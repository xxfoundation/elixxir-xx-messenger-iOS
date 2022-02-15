import UIKit
import Theme
import Shared
import Combine
import DependencyInjection

public enum PermissionType {
    case camera
    case library
    case microphone
}

public final class RequestPermissionController: UIViewController {
    @Dependency private var permissions: PermissionHandling
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = RequestPermissionView()

    private var type: PermissionType!
    private var cancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar.customize(backgroundColor: Asset.neutralWhite.color)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()
    }

    public func setup(type: PermissionType) {
        self.type = type

        switch type {
        case .camera:
            screenView.setup(
                title: Localized.Chat.Actions.Permission.Camera.title,
                subtitle: Localized.Chat.Actions.Permission.Camera.subtitle,
                image: Asset.permissionCamera.image
            )
        case .library:
            screenView.setup(
                title: Localized.Chat.Actions.Permission.Library.title,
                subtitle: Localized.Chat.Actions.Permission.Library.subtitle,
                image: Asset.permissionLibrary.image
            )
        case .microphone:
            screenView.setup(
                title: Localized.Chat.Actions.Permission.Microphone.title,
                subtitle: Localized.Chat.Actions.Permission.Microphone.subtitle,
                image: Asset.permissionMicrophone.image
            )
        }
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
    }

    private func setupBindings() {
        screenView.notNowButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }.store(in: &cancellables)

        screenView.continueButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                switch type {
                case .camera:
                    permissions.requestCamera { [weak self] _ in
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                case .library:
                    permissions.requestPhotos { [weak self] _ in
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                case .microphone:
                    permissions.requestMicrophone { [weak self] _ in
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                case .none:
                    break
                }
            }.store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
