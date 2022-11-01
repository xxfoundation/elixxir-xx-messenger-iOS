import UIKit
import Models
import Shared
import Combine
import XXModels
import Countries
import DrawerFeature
import DependencyInjection

final class RequestsReceivedController: UIViewController {
    @Dependency var toaster: ToastController
    @Dependency var coordinator: RequestsCoordinating

    lazy private var screenView = RequestsReceivedView()
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
                guard let self = self else { return }
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

        viewModel.verifyingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in presentVerifyingDrawer() }
            .store(in: &cancellables)

        viewModel.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in dataSource?.apply($0, animatingDifferences: true) }
            .store(in: &cancellables)

        viewModel.contactConfirmationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in presentSingleRequestSuccessDrawer(forContact: $0) }
            .store(in: &cancellables)

        viewModel.groupConfirmationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in presentGroupRequestSuccessDrawer(forGroup: $0) }
            .store(in: &cancellables)
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

        let drawer = DrawerController(with: items)

        drawerSendButton.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                drawer.dismiss(animated: true) {
                    let chatInfo = self.viewModel.groupChatWith(group: group)
                    self.coordinator.toGroupChat(with: chatInfo, from: self)
                }
            }.store(in: &drawerCancellables)

        drawerLaterButton.action
            .sink { drawer.dismiss(animated: true) }
            .store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
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

        let drawer = DrawerController(with: items)

        drawerSendButton.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                drawer.dismiss(animated: true) {
                    self.coordinator.toSingleChat(with: contact, from: self)
                }
            }.store(in: &drawerCancellables)

        drawerLaterButton.action
            .receive(on: DispatchQueue.main)
            .sink { drawer.dismiss(animated: true) }
            .store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
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

        let drawer = DrawerController(with: items)

        drawerAcceptButton.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                drawer.dismiss(animated: true) {
                    self.viewModel.didRequestAccept(group: group)
                }
            }
            .store(in: &drawerCancellables)

        drawerHideButton.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                drawer.dismiss(animated: true) {
                    self.viewModel.didRequestHide(group: group)
                }
            }
            .store(in: &drawerCancellables)

        coordinator.toDrawerBottom(drawer, from: self)
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

        let drawer = DrawerController(with: items)

        var nickname: String?
        var allowsSave = true

        drawerNicknameInput.validationPublisher
            .receive(on: DispatchQueue.main)
            .sink { allowsSave = $0 }
            .store(in: &drawerCancellables)

        drawerNicknameInput.inputPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                guard !$0.isEmpty else {
                    nickname = contact.username
                    return
                }

                nickname = $0
            }
            .store(in: &drawerCancellables)

        drawerAcceptButton.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                guard allowsSave else { return }

                drawer.dismiss(animated: true) {
                    self.viewModel.didRequestAccept(contact: contact, nickname: nickname)
                }
            }
            .store(in: &drawerCancellables)

        drawerHideButton.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                drawer.dismiss(animated: true) {
                    self.viewModel.didRequestHide(contact: contact)
                }
            }
            .store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
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

        let drawer = DrawerController(with: items)

        drawerDoneButton.action
            .receive(on: DispatchQueue.main)
            .sink { drawer.dismiss(animated: true) }
            .store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }
}
