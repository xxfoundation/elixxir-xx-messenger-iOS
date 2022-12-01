import UIKit
import Shared
import Combine
import XXModels
import AppCore
import Dependencies
import AppResources
import AppNavigation
import DrawerFeature
import ScrollViewController

public final class ContactController: UIViewController {
  @Dependency(\.navigator) var navigator
  @Dependency(\.app.statusBar) var statusBar

  private lazy var screenView = ContactView()
  private lazy var scrollViewController = ScrollViewController()

  private let viewModel: ContactViewModel
  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()

  public init(_ model: Contact) {
    self.viewModel = ContactViewModel(model)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    statusBar.set(.lightContent)
    navigationController?.navigationBar
      .customize(
        backgroundColor: Asset.neutralBody.color,
        tint: Asset.neutralWhite.color
      )
  }

  public override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    screenView.updateTopOffset(-view.safeAreaInsets.top)
    screenView.updateBottomOffset(view.safeAreaInsets.bottom)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupScrollView()
    setupBindings()

    screenView.didTapSend = { [weak self] in
      guard let self else { return }
      self.navigator.perform(PresentChat(
        contact: self.viewModel.contact,
        on: self.navigationController!
      ))
    }
    screenView.didTapInfo = { [weak self] in
      guard let self else { return }
      self.presentInfo(
        title: Localized.Contact.SendMessage.Info.title,
        subtitle: Localized.Contact.SendMessage.Info.subtitle,
        urlString: "https://links.xx.network/cmix"
      )
    }

    screenView.set(status: viewModel.contact.authStatus)
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
    screenView
      .cardComponent
      .avatarView
      .editButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(
          PresentPhotoLibrary(from: self)
        )
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.photo)
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.cardComponent.image = $0
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.title)
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.cardComponent.nameLabel.text = $0
      }.store(in: &cancellables)

    viewModel
      .popPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigationController?.popViewController(animated: true)
      }.store(in: &cancellables)

    viewModel
      .popToRootPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigationController?.popToRootViewController(animated: true)
      }.store(in: &cancellables)

    viewModel
      .successPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.updateToSuccess()
      }.store(in: &cancellables)

    setupScannedBindings()
    setupReceivedBindings()
    setupConfirmedBindings()
    setupInProgressBindings()
    setupSuccessBindings()
  }

  private func setupSuccessBindings() {
    screenView
      .successView
      .keepAdding
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        navigationController?.popViewController(animated: true)
      }.store(in: &cancellables)

    screenView
      .successView
      .sentRequests
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        navigator.perform(PresentRequests(on: navigationController!))
      }.store(in: &cancellables)

    viewModel
      .statePublisher
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
    screenView
      .scannedView.add
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        let nickname = (viewModel.contact.nickname ?? viewModel.contact.username) ?? ""
        navigator.perform(PresentNickname(prefilled: nickname, completion: { [weak self] in
          guard let self else { return }
          self.viewModel.didTapRequest(with: $0)
        }, from: self))
      }.store(in: &cancellables)
  }

  private func setupReceivedBindings() {
    screenView
      .receivedView.accept
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        let nickname = (viewModel.contact.nickname ?? viewModel.contact.username) ?? ""
        navigator.perform(PresentNickname(prefilled: nickname, completion: { [weak self] in
          guard let self else { return }
          self.viewModel.didTapAccept($0)
        }, from: self))
      }.store(in: &cancellables)

    screenView
      .receivedView.reject
      .publisher(for: .touchUpInside)
      .sink { [weak viewModel] in
        viewModel?.didTapReject()
      }.store(in: &cancellables)
  }

  private func setupInProgressBindings() {
    viewModel
      .statePublisher
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

    screenView
      .inProgressView.feedback
      .button.publisher(for: .touchUpInside)
      .sink { [weak viewModel] in
        viewModel?.didTapResend()
      }.store(in: &cancellables)
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

        nicknameAttribute
          .actionButton
          .publisher(for: .touchUpInside)
          .sink { [unowned self] in
            let nickname = (viewModel.contact.nickname ?? viewModel.contact.username) ?? ""
            navigator.perform(PresentNickname(prefilled: nickname, completion: { [weak self] in
              guard let self else { return }
              self.viewModel.didUpdateNickname($0)
            }, from: self))
          }.store(in: &cancellables)

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
          title: Localized.Contact.Delete.Info.title,
          icon: Asset.settingsDelete.image,
          style: .delete,
          separator: false
        )

        screenView.confirmedView.stackView.addArrangedSubview(deleteButton)

        deleteButton.publisher(for: .touchUpInside)
          .sink { [unowned self] in presentDeleteInfo() }
          .store(in: &cancellables)
      }.store(in: &cancellables)

    screenView
      .confirmedView
      .clearButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        presentClearDrawer()
      }.store(in: &cancellables)
  }

  private func presentClearDrawer() {
    let clearButton = CapsuleButton()
    clearButton.setStyle(.red)
    clearButton.setTitle(Localized.Contact.Clear.action, for: .normal)

    let cancelButton = CapsuleButton()
    cancelButton.setStyle(.seeThrough)
    cancelButton.setTitle(Localized.Contact.Clear.cancel, for: .normal)

    clearButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          self.viewModel.didTapClear()
        }
      }.store(in: &drawerCancellables)

    cancelButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: [
      DrawerImage(
        image: Asset.drawerNegative.image
      ),
      DrawerText(
        font: Fonts.Mulish.semiBold.font(size: 18.0),
        text: Localized.Contact.Clear.title,
        color: Asset.neutralActive.color
      ),
      DrawerText(
        font: Fonts.Mulish.semiBold.font(size: 14.0),
        text: Localized.Contact.Clear.subtitle,
        color: Asset.neutralWeak.color,
        lineHeightMultiple: 1.35,
        spacingAfter: 25
      ),
      DrawerStack(
        spacing: 20.0,
        views: [clearButton, cancelButton]
      )
    ], isDismissable: true, from: self))
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
      title: Localized.Settings.InfoDrawer.action
    )

    actionButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: [
      DrawerText(
        font: Fonts.Mulish.bold.font(size: 26.0),
        text: title,
        color: Asset.neutralActive.color,
        alignment: .left,
        spacingAfter: 19
      ),
      DrawerLinkText(
        text: subtitle,
        urlString: urlString,
        spacingAfter: 37
      ),
      DrawerStack(views: [
        actionButton,
        FlexibleSpace()
      ])
    ], isDismissable: true, from: self))
  }

  private func presentDeleteInfo() {
    let actionButton = DrawerCapsuleButton(model: .init(
      title: Localized.Contact.Delete.Info.title,
      style: .red
    ))

    actionButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          self.viewModel.didTapDelete()
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: [
      DrawerText(
        font: Fonts.Mulish.bold.font(size: 26.0),
        text: Localized.Contact.Delete.Drawer.title,
        color: Asset.neutralActive.color,
        alignment: .left,
        spacingAfter: 19
      ),
      DrawerText(
        text: Localized.Contact.Delete.Drawer.description(viewModel.contact.username ?? ""),
        spacingAfter: 37,
        customAttributes: [.font:  Fonts.Mulish.bold.font(size: 16.0)]
      ),
      actionButton
    ], isDismissable: true, from: self))
  }
}
