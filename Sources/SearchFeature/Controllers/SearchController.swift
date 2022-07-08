import HUD
import Theme
import UIKit
import Shared
import Models
import Combine
import Defaults
import XXModels
import Countries
import DrawerFeature
import DependencyInjection
import ScrollViewController

final class SearchController: UIViewController {
    @KeyObject(.email, defaultValue: nil) var email: String?
    @KeyObject(.phone, defaultValue: nil) var phone: String?
    @KeyObject(.sharingEmail, defaultValue: false) var isSharingEmail: Bool
    @KeyObject(.sharingPhone, defaultValue: false) var isSharingPhone: Bool

    @Dependency private var hud: HUDType
    @Dependency private var coordinator: SearchCoordinating

    lazy private var tableController = SearchTableController(viewModel)
    lazy private var screenView = SearchView {
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .seeThrough,
            title: Localized.Ud.Placeholder.Drawer.action
        )

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.Ud.Placeholder.Drawer.title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            DrawerLinkText(
                text: Localized.Ud.Placeholder.Drawer.subtitle,
                urlString: "https://links.xx.network/adrp",
                spacingAfter: 37
            ),
            DrawerStack(views: [
                actionButton,
                FlexibleSpace()
            ])
        ])

        actionButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                }
            }.store(in: &self.drawerCancellables)

        self.coordinator.toDrawer(drawer, from: self)
    }

    private let viewModel = SearchViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

    override func loadView() {
        view = screenView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupBindings()
        setupFilterBindings()
    }

    private func setupTableView() {
        addChild(tableController)
        screenView.addSubview(tableController.view)

        tableController.view.snp.makeConstraints {
            $0.top.equalTo(screenView.stack.snp.bottom).offset(20)
            $0.left.bottom.right.equalToSuperview()
        }

        tableController.didMove(toParent: self)
        tableController.tableView.delegate = self
        screenView.bringSubviewToFront(screenView.empty)
        screenView.bringSubviewToFront(screenView.placeholder)
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = " "

        let titleLabel = UILabel()
        titleLabel.text = Localized.Ud.title
        titleLabel.textColor = Asset.neutralActive.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let backButton = UIButton.back()
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [backButton, titleLabel])
        )
    }

    private func setupBindings() {
        viewModel.successPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in presentSucessDrawerFor(contact: $0) }
            .store(in: &cancellables)

        viewModel.hudPublisher
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        viewModel.coverTrafficPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in presentCoverTrafficDrawer() }
            .store(in: &cancellables)

        viewModel
            .itemsRelay
            .removeDuplicates()
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.empty.isHidden = $0 > 0 }
            .store(in: &cancellables)

        viewModel.placeholderPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.placeholder.isHidden = !$0 }
            .store(in: &cancellables)

        viewModel.statePublisher
            .map(\.country)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                screenView.phoneInput.set(prefix: $0.prefixWithFlag)
                screenView.phoneInput.update(placeholder: $0.example)
            }
            .store(in: &cancellables)

        screenView.input
            .textPublisher
            .removeDuplicates()
            .compactMap { $0 }
            .sink { [unowned self] in viewModel.didInput($0) }
            .store(in: &cancellables)

        screenView.input
            .returnPublisher
            .sink { [unowned self] in viewModel.didTapSearch() }
            .store(in: &cancellables)

        screenView.phoneInput
            .returnPublisher
            .sink { [unowned self] in viewModel.didTapSearch() }
            .store(in: &cancellables)

        screenView
            .phoneInput
            .textPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in viewModel.didInputPhone($0) }
            .store(in: &cancellables)

        screenView
            .phoneInput
            .codePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                coordinator.toCountries(from: self) {
                    self.viewModel.didChooseCountry($0)
                }
            }.store(in: &cancellables)
    }

    private func setupFilterBindings() {
        screenView.username
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in viewModel.didSelect(filter: .username) }
            .store(in: &cancellables)

        screenView.phone
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in viewModel.didSelect(filter: .phone) }
            .store(in: &cancellables)

        screenView.email
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in viewModel.didSelect(filter: .email) }
            .store(in: &cancellables)

        viewModel.statePublisher
            .map(\.selectedFilter)
            .removeDuplicates()
            .sink { [unowned self] in screenView.alternateFieldsOver(filter: $0) }
            .store(in: &cancellables)

        viewModel.statePublisher
            .map(\.selectedFilter)
            .removeDuplicates()
            .dropFirst()
            .sink { [unowned self] in screenView.select(filter: $0) }
            .store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = viewModel.itemsRelay.value[indexPath.row]

        guard contact.authStatus == .stranger else {
            coordinator.toContact(contact, from: self)
            return
        }

        presentRequestDrawer(forContact: contact)
    }
}

extension SearchController: UITableViewDelegate {}

// MARK: - Contact Request Drawer

extension SearchController {
    private func presentRequestDrawer(forContact contact: Contact) {
        var items: [DrawerItem] = []

        let drawerTitle = DrawerText(
            font: Fonts.Mulish.extraBold.font(size: 26.0),
            text: Localized.Ud.RequestDrawer.title,
            color: Asset.neutralDark.color,
            spacingAfter: 20
        )

        var subtitleFragment = "Share your information with #\(contact.username ?? "")"

        if let email = contact.email {
            subtitleFragment.append(contentsOf: " (\(email))#")
        } else if let phone = contact.phone {
            subtitleFragment.append(contentsOf: " (\(Country.findFrom(phone).prefix) \(phone.dropLast(2)))#")
        } else {
            subtitleFragment.append(contentsOf: "#")
        }

        subtitleFragment.append(contentsOf: " so they know its you.")

        let drawerSubtitle = DrawerText(
            font: Fonts.Mulish.regular.font(size: 16.0),
            text: subtitleFragment,
            color: Asset.neutralDark.color,
            spacingAfter: 31.5,
            customAttributes: [
                .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
                .foregroundColor: Asset.brandPrimary.color
            ]
        )

        items.append(contentsOf: [
            drawerTitle,
            drawerSubtitle
        ])

        if let email = email {
            let drawerEmail = DrawerSwitch(
                title: Localized.Ud.RequestDrawer.email,
                content: email,
                spacingAfter: phone != nil ? 23 : 31,
                isInitiallyOn: isSharingEmail
            )

            items.append(drawerEmail)

            drawerEmail.isOnPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.isSharingEmail = $0 }
                .store(in: &drawerCancellables)
        }

        if let phone = phone {
            let drawerPhone = DrawerSwitch(
                title: Localized.Ud.RequestDrawer.phone,
                content: "\(Country.findFrom(phone).prefix) \(phone.dropLast(2))",
                spacingAfter: 31,
                isInitiallyOn: isSharingPhone
            )

            items.append(drawerPhone)

            drawerPhone.isOnPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.isSharingPhone = $0 }
                .store(in: &drawerCancellables)
        }

        let drawerSendButton = DrawerCapsuleButton(
            model: .init(
                title: Localized.Ud.RequestDrawer.send,
                style: .brandColored
            ), spacingAfter: 5
        )

        let drawerCancelButton = DrawerCapsuleButton(
            model: .init(
                title: Localized.Ud.RequestDrawer.cancel,
                style: .simplestColoredBrand
            ), spacingAfter: 5
        )

        items.append(contentsOf: [drawerSendButton, drawerCancelButton])
        let drawer = DrawerController(with: items)

        drawerSendButton.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                drawer.dismiss(animated: true) {
                    self.viewModel.didTapRequest(contact: contact)
                }
            }.store(in: &drawerCancellables)

        drawerCancelButton.action
            .receive(on: DispatchQueue.main)
            .sink { drawer.dismiss(animated: true) }
            .store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }
}

// MARK: - Cover Traffic Drawer

extension SearchController {
    private func presentCoverTrafficDrawer() {
        let enableButton = CapsuleButton()
        enableButton.set(
            style: .brandColored,
            title: Localized.ChatList.Traffic.positive
        )

        let dismissButton = CapsuleButton()
        dismissButton.set(
            style: .seeThrough,
            title: Localized.ChatList.Traffic.negative
        )

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.ChatList.Traffic.title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            DrawerText(
                font: Fonts.Mulish.regular.font(size: 16.0),
                text: Localized.ChatList.Traffic.subtitle,
                color: Asset.neutralBody.color,
                alignment: .left,
                lineHeightMultiple: 1.1,
                spacingAfter: 39
            ),
            DrawerStack(
                axis: .horizontal,
                spacing: 20,
                distribution: .fillEqually,
                views: [enableButton, dismissButton]
            )
        ])

        enableButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                    self.viewModel.didEnableCoverTraffic()
                }
            }.store(in: &drawerCancellables)

        dismissButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }
}

extension SearchController {
    private func presentSucessDrawerFor(contact: Contact) {
        var items: [DrawerItem] = []

        let drawerTitle = DrawerText(
            font: Fonts.Mulish.extraBold.font(size: 26.0),
            text: Localized.Ud.NicknameDrawer.title,
            color: Asset.neutralDark.color,
            spacingAfter: 20
        )

        let drawerSubtitle = DrawerText(
            font: Fonts.Mulish.regular.font(size: 16.0),
            text: Localized.Ud.NicknameDrawer.subtitle,
            color: Asset.neutralDark.color,
            spacingAfter: 20
        )

        items.append(contentsOf: [
            drawerTitle,
            drawerSubtitle
        ])

        let drawerNicknameInput = DrawerInput(
            placeholder: contact.username!,
            validator: .init(
                wrongIcon: .image(Asset.sharedError.image),
                correctIcon: .image(Asset.sharedSuccess.image),
                shouldAcceptPlaceholder: true
            ),
            spacingAfter: 29
        )

        items.append(drawerNicknameInput)

        let drawerSaveButton = DrawerCapsuleButton(
            model: .init(
                title: Localized.Ud.NicknameDrawer.save,
                style: .brandColored
            ), spacingAfter: 5
        )

        items.append(drawerSaveButton)

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

        drawerSaveButton.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                guard allowsSave else { return }

                drawer.dismiss(animated: true) {
                    self.viewModel.didSet(nickname: nickname ?? contact.username!, for: contact)
                }
            }
            .store(in: &drawerCancellables)

        coordinator.toNicknameDrawer(drawer, from: self)
    }
}
