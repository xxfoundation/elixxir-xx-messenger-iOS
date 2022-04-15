import HUD
import Popup
import UIKit
import Theme
import Shared
import Models
import Combine
import DependencyInjection
import ScrollViewController

public final class ContactController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: ContactCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = ContactView()
    lazy private var scrollViewController = ScrollViewController()

    private let viewModel: ContactViewModel
    private var cancellables = Set<AnyCancellable>()
    private var popupCancellables = Set<AnyCancellable>()

    public init(_ model: Contact) {
        self.viewModel = ContactViewModel(model)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.lightContent)
        navigationController?.navigationBar
            .customize(backgroundColor: Asset.neutralBody.color)
    }

    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        screenView.updateTopOffset(-view.safeAreaInsets.top)
        screenView.updateBottomOffset(view.safeAreaInsets.bottom)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupScrollView()
        setupBindings()

        screenView.didTapSend = { [weak self] in
            guard let self = self else { return }
            self.coordinator.toSingleChat(with: self.viewModel.contact, from: self)
        }
        screenView.didTapInfo = { [weak self] in
            self?.presentInfo(
                title: Localized.Contact.SendMessage.Info.title,
                subtitle: Localized.Contact.SendMessage.Info.subtitle,
                urlString: "https://links.xx.network/cmix"
            )
        }

        screenView.set(status: viewModel.contact.status)
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let back = UIButton.back(color: Asset.neutralWhite.color)
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
    }

    private func setupScrollView() {
        addChild(scrollViewController)
        view.addSubview(scrollViewController.view)
        scrollViewController.view.backgroundColor = Asset.neutralWhite.color
        scrollViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollViewController.didMove(toParent: self)
        scrollViewController.contentView = screenView
        scrollViewController.scrollView.bounces = false
    }

    private func setupBindings() {
        viewModel.hudPublisher
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        screenView.cardComponent.avatarView.editButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toPhotos(from: self) }
            .store(in: &cancellables)

        viewModel.statePublisher
            .map(\.photo)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.cardComponent.image = $0 }
            .store(in: &cancellables)

        viewModel.statePublisher
            .map(\.title)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.cardComponent.nameLabel.text = $0 }
            .store(in: &cancellables)

        viewModel.popPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in navigationController?.popViewController(animated: true) }
            .store(in: &cancellables)

        viewModel.popToRootPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in navigationController?.popToRootViewController(animated: true) }
            .store(in: &cancellables)

        viewModel.successPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.updateToSuccess() }
            .store(in: &cancellables)

        setupScannedBindings()
        setupReceivedBindings()
        setupConfirmedBindings()
        setupInProgressBindings()
        setupSuccessBindings()
    }

    private func setupSuccessBindings() {
        screenView.successView.keepAdding
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in navigationController?.popViewController(animated: true) }
            .store(in: &cancellables)

        screenView.successView.sentRequests
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in coordinator.toRequests(from: self) }
            .store(in: &cancellables)

        viewModel.statePublisher
            .map(\.username)
            .removeDuplicates()
            .combineLatest(
                viewModel.statePublisher.map(\.email).removeDuplicates(),
                viewModel.statePublisher.map(\.phone).removeDuplicates()
            )
            .sink { [unowned self] in
                [Localized.Contact.username: $0.0,
                 Localized.Contact.email: $0.1,
                 Localized.Contact.phone: $0.2].forEach { pair in
                    guard let value = pair.value else { return }

                    let attributeView = AttributeComponent()
                    attributeView.set(
                        title: pair.key,
                        value: value
                    )

                    screenView.successView.stack.addArrangedSubview(attributeView)
                }
            }.store(in: &cancellables)
    }

    private func setupScannedBindings() {
        screenView.scannedView.add
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                coordinator.toNickname(
                    from: self,
                    prefilled: viewModel.contact.nickname ?? viewModel.contact.username,
                    viewModel.didTapRequest(with:)
                )
            }.store(in: &cancellables)
    }

    private func setupReceivedBindings() {
        screenView.receivedView.accept
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                coordinator.toNickname(
                    from: self,
                    prefilled: viewModel.contact.nickname ?? viewModel.contact.username,
                    viewModel.didTapAccept(_:)
                )
            }.store(in: &cancellables)

        screenView.receivedView.reject
            .publisher(for: .touchUpInside)
            .sink { [weak viewModel] in viewModel?.didTapReject() }
            .store(in: &cancellables)
    }

    private func setupInProgressBindings() {
        viewModel.statePublisher
            .map(\.username)
            .removeDuplicates()
            .combineLatest(
                viewModel.statePublisher.map(\.email).removeDuplicates(),
                viewModel.statePublisher.map(\.phone).removeDuplicates()
            )
            .sink { [unowned self] in
                [Localized.Contact.username: $0.0,
                 Localized.Contact.email: $0.1,
                 Localized.Contact.phone: $0.2].forEach { pair in
                    guard let value = pair.value else { return }

                    let attributeView = AttributeComponent()
                    attributeView.set(
                        title: pair.key,
                        value: value
                    )

                    screenView.inProgressView.stack.addArrangedSubview(attributeView)
                }
            }.store(in: &cancellables)

        screenView.inProgressView.feedback
            .button.publisher(for: .touchUpInside)
            .sink { [weak viewModel] in viewModel?.didTapResend() }
            .store(in: &cancellables)
    }

    private func setupConfirmedBindings() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map(\.nickname)
            .removeDuplicates()
            .combineLatest(
                viewModel.statePublisher.map(\.username).removeDuplicates(),
                viewModel.statePublisher.map(\.email).removeDuplicates(),
                viewModel.statePublisher.map(\.phone).removeDuplicates()
            )
            .sink { [unowned self] in
                screenView.confirmedView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

                let nicknameAttribute = AttributeComponent()
                nicknameAttribute.set(title: Localized.Contact.nickname, value: $0.0, style: .requiredEditable)
                screenView.confirmedView.stackView.insertArrangedSubview(nicknameAttribute, at: 0)

                nicknameAttribute.actionButton.publisher(for: .touchUpInside)
                    .sink { [unowned self] in
                        coordinator.toNickname(
                            from: self,
                            prefilled: viewModel.contact.nickname ?? viewModel.contact.username,
                            viewModel.didUpdateNickname(_:)
                        )
                    }
                    .store(in: &cancellables)

                let usernameAttribute = AttributeComponent()
                usernameAttribute.set(title: Localized.Contact.username, value: $0.1)
                screenView.confirmedView.stackView.addArrangedSubview(usernameAttribute)

                let emailAttribute = AttributeComponent()
                emailAttribute.set(title: Localized.Contact.email, value: $0.2)
                screenView.confirmedView.stackView.addArrangedSubview(emailAttribute)

                let phoneAttribute = AttributeComponent()
                phoneAttribute.set(title: Localized.Contact.phone, value: $0.3)
                screenView.confirmedView.stackView.addArrangedSubview(phoneAttribute)

                let deleteButton = RowButton()
                deleteButton.setup(
                    title: "Delete Connection",
                    icon: Asset.settingsDelete.image,
                    style: .delete,
                    separator: false
                )

                screenView.confirmedView.stackView.addArrangedSubview(deleteButton)

                deleteButton.publisher(for: .touchUpInside)
                    .sink { [unowned self] in presentDeleteInfo() }
                    .store(in: &cancellables)
            }.store(in: &cancellables)

        screenView.confirmedView.clearButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in presentClearPopup() }
            .store(in: &cancellables)
    }

    private func presentClearPopup() {
        let clearButton = CapsuleButton()
        clearButton.setStyle(.red)
        clearButton.setTitle(Localized.Contact.Clear.action, for: .normal)

        let cancelButton = CapsuleButton()
        cancelButton.setStyle(.seeThrough)
        cancelButton.setTitle(Localized.Contact.Clear.cancel, for: .normal)

        let popup = BottomPopup(with: [
            PopupImage(image: Asset.popupNegative.image),
            PopupLabel(
                font: Fonts.Mulish.semiBold.font(size: 18.0),
                text: Localized.Contact.Clear.title,
                color: Asset.neutralActive.color
            ),
            PopupLabel(
                font: Fonts.Mulish.semiBold.font(size: 14.0),
                text: Localized.Contact.Clear.subtitle,
                color: Asset.neutralWeak.color,
                lineHeightMultiple: 1.35,
                spacingAfter: 25
            ),
            PopupStackView(
                spacing: 20.0,
                views: [
                    clearButton,
                    cancelButton
                ]
            )
        ])

        clearButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                popup.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.popupCancellables.removeAll()
                    self.viewModel.didTapClear()
                }
            }.store(in: &popupCancellables)

        cancelButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                popup.dismiss(animated: true) { [weak self] in
                    self?.popupCancellables.removeAll()
                }
            }.store(in: &popupCancellables)

        coordinator.toPopup(popup, from: self)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension ContactController: UIImagePickerControllerDelegate {
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

extension ContactController: UINavigationControllerDelegate {}

extension ContactController {
    private func presentInfo(
        title: String,
        subtitle: String,
        urlString: String = ""
    ) {
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .seeThrough,
            title: Localized.Settings.InfoPopUp.action
        )

        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            PopupLinkText(
                text: subtitle,
                urlString: urlString,
                spacingAfter: 37
            ),
            PopupStackView(views: [actionButton, FlexibleSpace()])
        ])

        actionButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                popup.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.popupCancellables.removeAll()
                }
            }.store(in: &popupCancellables)

        coordinator.toPopup(popup, from: self)
    }

    private func presentDeleteInfo() {
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .red,
            title: "Delete Connection"
        )

        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: "Delete Connection?",
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            PopupLabelAttributed(
                text: "This is a silent deletion, \(viewModel.contact.username) will not know you deleted them. This action will remove all information on your phone about this user, including your communications. You #cannot undo this step, and cannot re-add them unless they delete you as a connection as well.#",
                spacingAfter: 37
                ),
            PopupStackView(views: [actionButton])
        ])

        actionButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                popup.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.popupCancellables.removeAll()
                    self.viewModel.didTapDelete()
                }
            }.store(in: &popupCancellables)

        coordinator.toPopup(popup, from: self)
    }
}
