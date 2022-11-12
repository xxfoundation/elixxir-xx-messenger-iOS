import UIKit
import Shared
import Combine
import XXModels
import Countries
import XXNavigation
import DrawerFeature
import DI

final class RequestsReceivedController: UIViewController {
  @Dependency var navigator: Navigator
  @Dependency var toaster: ToastController

  private lazy var screenView = RequestsReceivedView()
  private var cancellables = Set<AnyCancellable>()
  private let viewModel = RequestsReceivedViewModel()
  private var drawerCancellables = Set<AnyCancellable>()
  private var dataSource: UICollectionViewDiffableDataSource<Section, RequestReceived>?

  override func loadView() {
    view = screenView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    screenView.collectionView.delegate = self
    screenView.collectionView.register(RequestCell.self)
    screenView.collectionView.register(RequestReceivedEmptyCell.self)
    screenView.collectionView.registerSectionHeader(RequestsBlankSectionHeader.self)
    screenView.collectionView.registerSectionHeader(RequestsHiddenSectionHeader.self)

    dataSource = UICollectionViewDiffableDataSource<Section, RequestReceived>(
      collectionView: screenView.collectionView
    ) { collectionView, indexPath, requestReceived in
      guard let request = requestReceived.request else {
        let cell: RequestReceivedEmptyCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        return cell
      }

      let cell: RequestCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
      cell.setupFor(requestReceived: requestReceived, isHidden: indexPath.section == 1)
      cell.didTapStateButton = { [weak self] in
        guard let self else { return }
        self.viewModel.didTapStateButtonFor(request: request)
      }

      return cell
    }

    dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      let reuseIdentifier: String

      if indexPath.section == Section.appearing.rawValue {
        reuseIdentifier = String(describing: RequestsBlankSectionHeader.self)
      } else {
        reuseIdentifier = String(describing: RequestsHiddenSectionHeader.self)
      }

      let cell = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: reuseIdentifier,
        for: indexPath
      )

      if let cell = cell as? RequestsHiddenSectionHeader, let self = self {
        cell.switcherView.setOn(self.viewModel.isShowingHiddenRequests, animated: true)

        cell.switcherView
          .publisher(for: .valueChanged)
          .sink { self.viewModel.didToggleHiddenRequestsSwitcher() }
          .store(in: &cell.cancellables)
      }

      return cell
    }

    viewModel
      .verifyingPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentVerifyingDrawer()
      }.store(in: &cancellables)

    viewModel
      .itemsPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dataSource?.apply($0, animatingDifferences: true)
      }.store(in: &cancellables)

    viewModel
      .contactConfirmationPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentSingleRequestSuccessDrawer(forContact: $0)
      }.store(in: &cancellables)

    viewModel
      .groupConfirmationPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentGroupRequestSuccessDrawer(forGroup: $0)
      }.store(in: &cancellables)
  }
}

extension RequestsReceivedController: UICollectionViewDelegate {
  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let request = dataSource?.itemIdentifier(for: indexPath)?.request else { return }

    switch request {
    case .group(let group):
      guard group.authStatus == .pending || group.authStatus == .hidden else { return }
      presentGroupRequestDrawer(forGroup: group)
    case .contact(let contact):
      guard contact.authStatus == .verified || contact.authStatus == .hidden else { return }
      presentSingleRequestDrawer(forContact: contact)
    }
  }
}

// MARK: - Group Request Success Drawer

extension RequestsReceivedController {
  func presentGroupRequestSuccessDrawer(forGroup group: Group) {
    drawerCancellables.removeAll()

    var items: [DrawerItem] = []

    let drawerTitle = DrawerText(
      font: Fonts.Mulish.bold.font(size: 12.0),
      text: Localized.Requests.Drawer.Group.Success.title,
      color: Asset.accentSuccess.color,
      spacingAfter: 20,
      leftImage: Asset.requestAccepted.image
    )

    let drawerNickname = DrawerText(
      font: Fonts.Mulish.extraBold.font(size: 26.0),
      text: group.name,
      color: Asset.neutralDark.color,
      spacingAfter: 20
    )

    let drawerSubtitle = DrawerText(
      font: Fonts.Mulish.regular.font(size: 16.0),
      text: Localized.Requests.Drawer.Group.Success.subtitle,
      color: Asset.neutralDark.color,
      spacingAfter: 20
    )

    items.append(contentsOf: [
      drawerTitle,
      drawerNickname,
      drawerSubtitle
    ])

    let drawerSendButton = DrawerCapsuleButton(
      model: .init(
        title: Localized.Requests.Drawer.Group.Success.send,
        style: .brandColored
      ), spacingAfter: 5
    )

    let drawerLaterButton = DrawerCapsuleButton(
      model: .init(
        title: Localized.Requests.Drawer.Group.Success.later,
        style: .simplestColoredBrand
      )
    )

    items.append(contentsOf: [
      drawerSendButton,
      drawerLaterButton
    ])

    drawerSendButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          self.navigator.perform(PresentGroupChat(
            model: self.viewModel.groupChatWith(group: group)
          ))
        }
      }.store(in: &drawerCancellables)

    drawerLaterButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: items))
  }
}

// MARK: - Single Request Success Drawer

extension RequestsReceivedController {
  func presentSingleRequestSuccessDrawer(forContact contact: Contact) {
    drawerCancellables.removeAll()

    var items: [DrawerItem] = []

    let drawerTitle = DrawerText(
      font: Fonts.Mulish.bold.font(size: 12.0),
      text: Localized.Requests.Drawer.Single.Success.title,
      color: Asset.accentSuccess.color,
      spacingAfter: 20,
      leftImage: Asset.requestAccepted.image
    )

    let drawerNickname = DrawerText(
      font: Fonts.Mulish.extraBold.font(size: 26.0),
      text: (contact.nickname ?? contact.username) ?? "",
      color: Asset.neutralDark.color,
      spacingAfter: 20
    )

    let drawerSubtitle = DrawerText(
      font: Fonts.Mulish.regular.font(size: 16.0),
      text: Localized.Requests.Drawer.Single.Success.subtitle,
      color: Asset.neutralDark.color,
      spacingAfter: 20
    )

    items.append(contentsOf: [
      drawerTitle,
      drawerNickname,
      drawerSubtitle
    ])

    let drawerSendButton = DrawerCapsuleButton(
      model: .init(
        title: Localized.Requests.Drawer.Single.Success.send,
        style: .brandColored
      ), spacingAfter: 5
    )

    let drawerLaterButton = DrawerCapsuleButton(
      model: .init(
        title: Localized.Requests.Drawer.Single.Success.later,
        style: .simplestColoredBrand
      )
    )

    items.append(contentsOf: [
      drawerSendButton,
      drawerLaterButton
    ])

    drawerSendButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          self.navigator.perform(PresentChat(contact: contact))
        }
      }.store(in: &drawerCancellables)

    drawerLaterButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: items))
  }
}

// MARK: - Group Request Drawer

extension RequestsReceivedController {
  func presentGroupRequestDrawer(forGroup group: Group) {
    drawerCancellables.removeAll()

    var items: [DrawerItem] = []

    let drawerTitle = DrawerText(
      font: Fonts.Mulish.bold.font(size: 12.0),
      text: Localized.Requests.Drawer.Group.title,
      spacingAfter: 20
    )

    let drawerGroupName = DrawerText(
      font: Fonts.Mulish.extraBold.font(size: 26.0),
      text: group.name,
      color: Asset.neutralDark.color,
      spacingAfter: 25
    )

    items.append(contentsOf: [
      drawerTitle,
      drawerGroupName
    ])

    let drawerLoading = DrawerLoadingRetry()
    drawerLoading.startSpinning()

    items.append(drawerLoading)

    let drawerTable = DrawerTable(spacingAfter: 23)

    drawerLoading.retryPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        drawerLoading.startSpinning()

        viewModel.fetchMembers(group) { [weak self] in
          guard let _ = self else { return }

          switch $0 {
          case .success(let models):
            DispatchQueue.main.async {
              drawerTable.update(models: models)
              drawerLoading.stopSpinning(withRetry: false)
            }
          case .failure:
            drawerLoading.stopSpinning(withRetry: true)
          }
        }
      }.store(in: &drawerCancellables)

    viewModel.fetchMembers(group) { [weak self] in
      guard let _ = self else { return }

      switch $0 {
      case .success(let models):
        DispatchQueue.main.async {
          drawerTable.update(models: models)
          drawerLoading.stopSpinning(withRetry: false)
        }
      case .failure:
        drawerLoading.stopSpinning(withRetry: true)
      }
    }

    items.append(drawerTable)

    let drawerAcceptButton = DrawerCapsuleButton(
      model: .init(
        title: Localized.Requests.Drawer.Group.accept,
        style: .brandColored
      ), spacingAfter: 5
    )

    let drawerHideButton = DrawerCapsuleButton(
      model: .init(
        title: Localized.Requests.Drawer.Group.hide,
        style: .simplestColoredBrand
      ), spacingAfter: 5
    )

    items.append(contentsOf: [drawerAcceptButton, drawerHideButton])

    drawerAcceptButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          self.viewModel.didRequestAccept(group: group)
        }
      }.store(in: &drawerCancellables)

    drawerHideButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          self.viewModel.didRequestHide(group: group)
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: items))
  }
}

// MARK: - Single Request Drawer

extension RequestsReceivedController {
  func presentSingleRequestDrawer(forContact contact: Contact) {
    drawerCancellables.removeAll()

    var items: [DrawerItem] = []

    let drawerTitle = DrawerText(
      font: Fonts.Mulish.bold.font(size: 12.0),
      text: Localized.Requests.Drawer.Single.title,
      spacingAfter: 20
    )

    let drawerUsername = DrawerText(
      font: Fonts.Mulish.extraBold.font(size: 26.0),
      text: contact.username ?? "",
      color: Asset.neutralDark.color,
      spacingAfter: 25
    )

    items.append(contentsOf: [
      drawerTitle,
      drawerUsername
    ])

    let drawerEmailTitle = DrawerText(
      font: Fonts.Mulish.bold.font(size: 12.0),
      text: Localized.Requests.Drawer.Single.email,
      color: Asset.neutralWeak.color,
      spacingAfter: 5
    )

    if let email = contact.email {
      let drawerEmailContent = DrawerText(
        font: Fonts.Mulish.regular.font(size: 16.0),
        text: email,
        spacingAfter: 25
      )

      items.append(contentsOf: [
        drawerEmailTitle,
        drawerEmailContent
      ])
    }

    let drawerPhoneTitle = DrawerText(
      font: Fonts.Mulish.bold.font(size: 12.0),
      text: Localized.Requests.Drawer.Single.phone,
      color: Asset.neutralWeak.color,
      spacingAfter: 5
    )

    if let phone = contact.phone {
      let drawerPhoneContent = DrawerText(
        font: Fonts.Mulish.regular.font(size: 16.0),
        text: "\(Country.findFrom(phone).prefix) \(phone.dropLast(2))",
        spacingAfter: 30
      )

      items.append(contentsOf: [
        drawerPhoneTitle,
        drawerPhoneContent
      ])
    }

    let drawerNicknameTitle = DrawerText(
      font: Fonts.Mulish.bold.font(size: 16.0),
      text: Localized.Requests.Drawer.Single.nickname,
      color: Asset.neutralDark.color,
      spacingAfter: 21
    )

    items.append(drawerNicknameTitle)

    let drawerNicknameInput = DrawerInput(
      placeholder: contact.username ?? "",
      validator: .init(
        wrongIcon: .image(Asset.sharedError.image),
        correctIcon: .image(Asset.sharedSuccess.image),
        shouldAcceptPlaceholder: true
      ),
      spacingAfter: 29
    )

    items.append(drawerNicknameInput)

    let drawerAcceptButton = DrawerCapsuleButton(
      model: .init(
        title: Localized.Requests.Drawer.Single.accept,
        style: .brandColored
      ), spacingAfter: 5
    )

    let drawerHideButton = DrawerCapsuleButton(
      model: .init(
        title: Localized.Requests.Drawer.Single.hide,
        style: .simplestColoredBrand
      ), spacingAfter: 5
    )

    items.append(contentsOf: [drawerAcceptButton, drawerHideButton])

    var nickname: String?
    var allowsSave = true

    drawerNicknameInput
      .validationPublisher
      .receive(on: DispatchQueue.main)
      .sink { allowsSave = $0 }
      .store(in: &drawerCancellables)

    drawerNicknameInput
      .inputPublisher
      .receive(on: DispatchQueue.main)
      .sink {
        guard !$0.isEmpty else {
          nickname = contact.username
          return
        }

        nickname = $0
      }.store(in: &drawerCancellables)

    drawerAcceptButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard allowsSave else { return }
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          self.viewModel.didRequestAccept(contact: contact, nickname: nickname)
        }
      }.store(in: &drawerCancellables)

    drawerHideButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          self.viewModel.didRequestHide(contact: contact)
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: items))
  }
}

// MARK: - Verifying Drawer

extension RequestsReceivedController {
  func presentVerifyingDrawer() {
    drawerCancellables.removeAll()

    var items: [DrawerItem] = []

    let drawerTitle = DrawerText(
      font: Fonts.Mulish.extraBold.font(size: 26.0),
      text: Localized.Requests.Received.Verifying.title,
      spacingAfter: 20
    )

    let drawerSubtitle = DrawerText(
      font: Fonts.Mulish.regular.font(size: 16.0),
      text: Localized.Requests.Received.Verifying.subtitle,
      spacingAfter: 40
    )

    items.append(contentsOf: [
      drawerTitle,
      drawerSubtitle
    ])

    let drawerDoneButton = DrawerCapsuleButton(
      model: .init(
        title: Localized.Requests.Received.Verifying.action,
        style: .brandColored
      ), spacingAfter: 5
    )

    items.append(drawerDoneButton)

    drawerDoneButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: items))
  }
}
