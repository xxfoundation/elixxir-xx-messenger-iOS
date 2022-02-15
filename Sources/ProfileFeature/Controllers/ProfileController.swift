import HUD
import Popup
import UIKit
import Theme
import Shared
import Combine
import DependencyInjection

public final class ProfileController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: ProfileCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = ProfileView()

    private let viewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var popupCancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.lightContent)
        navigationController?.navigationBar
            .customize(backgroundColor: Asset.neutralBody.color)
        viewModel.refresh()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        screenView.cardComponent.nameLabel.text = viewModel.username!
        setupNavigationBar()
        setupBindings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let back = UIButton.back(color: Asset.neutralWhite.color)
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
    }

    private func setupBindings() {
        viewModel.hud
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        screenView.emailView.actionButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                if screenView.emailView.currentValue != nil {
                    presentPopup(
                        title: Localized.Profile.Delete.title(
                            Localized.Profile.Email.title.capitalized
                        ),
                        subtitle: Localized.Profile.Delete.subtitle(
                            Localized.Profile.Email.title.lowercased(), Localized.Profile.Email.title.lowercased()
                        ),
                        actionTitle: Localized.Profile.Delete.action(
                            Localized.Profile.Email.title
                        )) {
                            viewModel.didTapDelete(isEmail: true)
                        }
                } else {
                    coordinator.toEmail(from: self)
                }
            }.store(in: &cancellables)

        screenView.phoneView.actionButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                if screenView.phoneView.currentValue != nil {
                    presentPopup(
                        title: Localized.Profile.Delete.title(
                            Localized.Profile.Phone.title.capitalized
                        ),
                        subtitle: Localized.Profile.Delete.subtitle(
                            Localized.Profile.Phone.title.lowercased(), Localized.Profile.Phone.title.lowercased()
                        ),
                        actionTitle: Localized.Profile.Delete.action(
                            Localized.Profile.Phone.title
                        )) {
                            viewModel.didTapDelete(isEmail: false)
                        }
                } else {
                    coordinator.toPhone(from: self)
                }
            }.store(in: &cancellables)

        screenView.cardComponent.avatarView.editButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in viewModel.didRequestLibraryAccess() }
            .store(in: &cancellables)

        viewModel.navigation
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [unowned self] in
                switch $0 {
                case .library:
                    presentPopup(
                        title: Localized.Profile.Photo.title,
                        subtitle: Localized.Profile.Photo.subtitle,
                        actionTitle: Localized.Profile.Photo.continue) {
                            coordinator.toPhotos(from: self)
                        }
                case .libraryPermission:
                    coordinator.toPermission(type: .library, from: self)
                case .none:
                    break
                }

                viewModel.didNavigateSomewhere()
            }.store(in: &cancellables)

        viewModel.state
            .map(\.email)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.emailView.set(value: $0) }
            .store(in: &cancellables)

        viewModel.state
            .map(\.phone)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.phoneView.set(value: $0) }
            .store(in: &cancellables)

        viewModel.state
            .map(\.photo)
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.cardComponent.image = $0 }
            .store(in: &cancellables)
    }

    private func presentPopup(
        title: String,
        subtitle: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) {
        let actionButton = PopupCapsuleButton(model: .init(title: actionTitle, style: .red))
        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            PopupLabel(
                font: Fonts.Mulish.regular.font(size: 16.0),
                text: subtitle,
                color: Asset.neutralBody.color,
                alignment: .left,
                lineHeightMultiple: 1.1,
                spacingAfter: 37
            ),
            actionButton
        ])

        actionButton.action
            .receive(on: DispatchQueue.main)
            .sink {
                popup.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.popupCancellables.removeAll()

                    action()
                }
            }.store(in: &popupCancellables)

        coordinator.toPopup(popup, from: self)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension ProfileController: UIImagePickerControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        var image: UIImage?

        if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }

        if let croppedImage = info[.editedImage] as? UIImage {
            image = croppedImage
        }

        guard let image = image else {
            picker.dismiss(animated: true)
            return
        }

        picker.dismiss(animated: true)
        viewModel.didChoosePhoto(image)
    }
}

extension ProfileController: UINavigationControllerDelegate {}
