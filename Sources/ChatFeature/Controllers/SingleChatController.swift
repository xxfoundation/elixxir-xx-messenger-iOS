import HUD
import UIKit
import Theme
import Models
import Shared
import Combine
import XXLogger
import QuickLook
import XXModels
import Voxophone
import ChatLayout
import DrawerFeature
import DifferenceKit
import ChatInputFeature
import ReportingFeature
import DependencyInjection
import ScrollViewController

extension FlexibleSpace: CollectionCellContent {
    func prepareForReuse() {}
}

extension Message: Differentiable {
    public var differenceIdentifier: Int64 { id! }
}

public final class SingleChatController: UIViewController {
    @Dependency private var hud: HUD
    @Dependency private var logger: XXLogger
    @Dependency private var voxophone: Voxophone
    @Dependency private var coordinator: ChatCoordinating
    @Dependency private var makeAppScreenshot: MakeAppScreenshot
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var infoView = UIControl()
    lazy private var nameLabel = UILabel()
    lazy private var avatarView = AvatarView()

    lazy private var moreButton = UIButton()
    lazy private var screenView = ChatView()
    lazy private var sheet = SheetController()

    private let inputComponent: ChatInputView
    private var collectionView: UICollectionView!

    private let chatLayout = ChatLayout()
    private var animator: ManualAnimator?
    private let viewModel: SingleChatViewModel
    private let layoutDelegate = LayoutDelegate()
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()
    private var sections = [ArraySection<ChatSection, Message>]()
    private var currentInterfaceActions: SetActor<Set<InterfaceActions>, ReactionTypes> = SetActor()

    var fileURL: URL?

    public override func loadView() { view = screenView }
    public override var canBecomeFirstResponder: Bool { true }
    public override var inputAccessoryView: UIView? { inputComponent }

    public init(_ contact: Contact) {
        let viewModel = SingleChatViewModel(contact)
        self.viewModel = viewModel

        self.inputComponent = ChatInputView(store: .init(
            initialState: .init(canAddAttachments: true),
            reducer: chatInputReducer,
            environment: .init(
                voxophone: try! DependencyInjection.Container.shared.resolve() as Voxophone,
                sendAudio: { viewModel.didSendAudio(url: $0) },
                didTapCamera: { viewModel.didTest(permission: .camera) },
                didTapLibrary: { viewModel.didTest(permission: .library) },
                sendText: { viewModel.send($0) },
                didTapAbortReply: { viewModel.abortReply() },
                didTapMicrophone: { viewModel.didTest(permission: .microphone) }
            )
        ))

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar.customize(
            backgroundColor: Asset.neutralWhite.color,
            shadowColor: Asset.neutralDisabled.color
        )
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.invalidateLayout()
        becomeFirstResponder()
        viewModel.viewDidAppear()
    }

    private var isFirstAppearance = true

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isFirstAppearance {
            isFirstAppearance = false
            let insets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: inputComponent.bounds.height - view.safeAreaInsets.bottom,
                right: 0
            )
            collectionView.contentInset = insets
            collectionView.scrollIndicatorInsets = insets
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.readAll()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewModel
            .contactPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in setupNavigationBar(contact: $0) }
            .store(in: &cancellables)

        setupCollectionView()
        setupInputController()
        setupBindings()

        KeyboardListener.shared.add(delegate: self)
    }

    // MARK: Private

    private func setupCollectionView() {
        chatLayout.configure(layoutDelegate)
        collectionView = .init(on: screenView, with: chatLayout)
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(OutgoingTextCell.self)
        collectionView.register(IncomingTextCell.self)
        collectionView.register(IncomingAudioCell.self)
        collectionView.register(OutgoingAudioCell.self)
        collectionView.register(IncomingImageCell.self)
        collectionView.register(IncomingReplyCell.self)
        collectionView.register(OutgoingImageCell.self)
        collectionView.register(OutgoingReplyCell.self)
        collectionView.register(OutgoingFailedTextCell.self)
        collectionView.register(OutgoingFailedReplyCell.self)

        collectionView.registerSectionHeader(SectionHeaderView.self)
    }

    private func setupNavigationBar(contact: Contact) {
        screenView.set(name: contact.nickname ?? contact.username!)
        avatarView.snp.makeConstraints { $0.width.height.equalTo(35) }

        let title = (contact.nickname ?? contact.username) ?? ""
        avatarView.setupProfile(title: title, image: contact.photo, size: .small)

        nameLabel.text = title
        nameLabel.textColor = Asset.neutralActive.color
        nameLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)

        moreButton.setImage(Asset.chatMore.image, for: .normal)
        moreButton.addTarget(self, action: #selector(didTapDots), for: .touchUpInside)

        infoView.addTarget(self, action: #selector(didTapInfo), for: .touchUpInside)

        infoView.addSubview(avatarView)
        infoView.addSubview(nameLabel)

        avatarView.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview()
        }

        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(avatarView.snp.right).offset(13)
            $0.right.lessThanOrEqualToSuperview()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: infoView)
        navigationItem.leftItemsSupplementBackButton = true
    }

    private func setupInputController() {
        inputComponent.setMaxHeight { [weak self] in
            guard let self = self else { return 150 }

            let maxHeight = self.collectionView.frame.height
            - self.collectionView.adjustedContentInset.top
            - self.collectionView.adjustedContentInset.bottom
            + self.inputComponent.bounds.height

            return maxHeight * 0.9
        }

        viewModel.replyPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] senderTitle, messageText in
                inputComponent.setupReply(message: messageText, sender: senderTitle)
            }
            .store(in: &cancellables)

        viewModel.navigation
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [unowned self] in
                switch $0 {
                case .library:
                    coordinator.toLibrary(from: self)
                case .camera:
                    coordinator.toCamera(from: self)
                case .cameraPermission:
                    coordinator.toPermission(type: .camera, from: self)
                case .microphonePermission:
                     coordinator.toPermission(type: .microphone, from: self)
                case .libraryPermission:
                    coordinator.toPermission(type: .library, from: self)
                case .webview(let urlString):
                    coordinator.toWebview(with: urlString, from: self)
                case .waitingRound:
                    coordinator.toDrawer(makeWaitingRoundDrawer(), from: self)
                case .none:
                    break
                }

                viewModel.didNavigateSomewhere()
            }.store(in: &cancellables)
    }

    private func setupBindings() {
        viewModel.hud
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        sheet.actionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                switch $0 {
                case .clear:
                    presentDeleteAllDrawer()
                case .details:
                    coordinator.toContact(viewModel.contact, from: self)
                case .report:
                    presentReportDrawer()
                }
            }.store(in: &cancellables)

        viewModel
            .shouldDisplayEmptyView
            .removeDuplicates()
            .sink { [unowned self] in
                screenView.titleLabel.isHidden = !$0

                if $0 == true {
                    screenView.bringSubviewToFront(screenView.titleLabel)
                }
            }.store(in: &cancellables)

        viewModel.reportPopupPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                presentReportDrawer()
            }.store(in: &cancellables)

        viewModel.isOnline
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak screenView] in screenView?.displayNetworkIssue(!$0) }
            .store(in: &cancellables)

        viewModel.messages
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] sections in
                func process() {
                    let changeSet = StagedChangeset(source: self.sections, target: sections).flattenIfPossible()
                    collectionView.reload(
                        using: changeSet,
                        interrupt: { changeSet in
                            guard !self.sections.isEmpty else { return true }
                            return false
                        }, onInterruptedReload: {
                            guard let lastSection = self.sections.last else { return }
                            let positionSnapshot = ChatLayoutPositionSnapshot(
                                indexPath: IndexPath(
                                    item: lastSection.elements.count - 1,
                                    section: self.sections.count - 1
                                ),
                                kind: .cell,
                                edge: .bottom
                            )

                            self.collectionView.reloadData()
                            self.chatLayout.restoreContentOffset(with: positionSnapshot)
                        },
                        completion: nil,
                        setData: { self.sections = $0 }
                    )
                }

                guard currentInterfaceActions.options.isEmpty else {
                    let reaction = SetActor<Set<InterfaceActions>, ReactionTypes>.Reaction(
                        type: .delayedUpdate,
                        action: .onEmpty,
                        executionType: .once,
                        actionBlock: { [weak self] in
                            guard let _ = self else { return }
                            process()
                        }
                    )

                    currentInterfaceActions.add(reaction: reaction)
                    return
                }

                process()
            }
            .store(in: &cancellables)
    }

    func scrollToBottom(completion: (() -> Void)? = nil) {
        let contentOffsetAtBottom = CGPoint(
            x: collectionView.contentOffset.x,
            y: chatLayout.collectionViewContentSize.height
            - collectionView.frame.height + collectionView.adjustedContentInset.bottom
        )

        guard contentOffsetAtBottom.y > collectionView.contentOffset.y else { completion?(); return }

        let initialOffset = collectionView.contentOffset.y
        let delta = contentOffsetAtBottom.y - initialOffset

        if abs(delta) > chatLayout.visibleBounds.height {
            animator = ManualAnimator()
            animator?.animate(duration: TimeInterval(0.25), curve: .easeInOut) { [weak self] percentage in
                guard let self = self else { return }

                self.collectionView.contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: initialOffset + (delta * percentage))
                if percentage == 1.0 {
                    self.animator = nil
                    let positionSnapshot = ChatLayoutPositionSnapshot(indexPath: IndexPath(item: 0, section: 0), kind: .footer, edge: .bottom)
                    self.chatLayout.restoreContentOffset(with: positionSnapshot)
                    self.currentInterfaceActions.options.remove(.scrollingToBottom)
                    completion?()
                }
            }
        } else {
            currentInterfaceActions.options.insert(.scrollingToBottom)
            UIView.animate(withDuration: 0.25, animations: {
                self.collectionView.setContentOffset(contentOffsetAtBottom, animated: true)
            }, completion: { [weak self] _ in
                self?.currentInterfaceActions.options.remove(.scrollingToBottom)
                completion?()
            })
        }
    }

    private func makeWaitingRoundDrawer() -> UIViewController {
        let text = DrawerText(
            font: Fonts.Mulish.semiBold.font(size: 14.0),
            text: Localized.Chat.RoundDrawer.title,
            color: Asset.neutralWeak.color,
            lineHeightMultiple: 1.35,
            spacingAfter: 25
        )

        let button = DrawerCapsuleButton(model: .init(
            title: Localized.Chat.RoundDrawer.action,
            style: .brandColored
        ))

        let drawer = DrawerController(with: [text, button])

        button.action
            .receive(on: DispatchQueue.main)
            .sink { [weak drawer] in
                drawer?.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        return drawer
    }

    private func presentReportDrawer() {
        let cancelButton = CapsuleButton()
        cancelButton.setStyle(.seeThrough)
        cancelButton.setTitle(Localized.Chat.Report.cancel, for: .normal)

        let reportButton = CapsuleButton()
        reportButton.setStyle(.red)
        reportButton.setTitle(Localized.Chat.Report.action, for: .normal)

        let drawer = DrawerController(with: [
            DrawerImage(
                image: Asset.drawerNegative.image
            ),
            DrawerText(
                font: Fonts.Mulish.semiBold.font(size: 18.0),
                text: Localized.Chat.Report.title,
                color: Asset.neutralActive.color
            ),
            DrawerText(
                font: Fonts.Mulish.semiBold.font(size: 14.0),
                text: Localized.Chat.Report.subtitle,
                color: Asset.neutralWeak.color,
                lineHeightMultiple: 1.35,
                spacingAfter: 25
            ),
            DrawerStack(
                axis: .vertical,
                spacing: 20.0,
                views: [reportButton, cancelButton]
            )
        ])

        reportButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                    self.viewModel.proceeedWithReport(screenshot: try! self.makeAppScreenshot()) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }.store(in: &drawerCancellables)

        cancelButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    self?.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }

    private func presentDeleteAllDrawer() {
        let clearButton = CapsuleButton()
        clearButton.setStyle(.red)
        clearButton.setTitle(Localized.Chat.Clear.action, for: .normal)

        let cancelButton = CapsuleButton()
        cancelButton.setStyle(.seeThrough)
        cancelButton.setTitle(Localized.Chat.Clear.cancel, for: .normal)

        let drawer = DrawerController(with: [
            DrawerImage(
                image: Asset.drawerNegative.image
            ),
            DrawerText(
                font: Fonts.Mulish.semiBold.font(size: 18.0),
                text: Localized.Chat.Clear.title,
                color: Asset.neutralActive.color
            ),
            DrawerText(
                font: Fonts.Mulish.semiBold.font(size: 14.0),
                text: Localized.Chat.Clear.subtitle,
                color: Asset.neutralWeak.color,
                lineHeightMultiple: 1.35,
                spacingAfter: 25
            ),
            DrawerStack(
                spacing: 20.0,
                views: [clearButton, cancelButton]
            )
        ])

        clearButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                    self.viewModel.didRequestDeleteAll()
                }
            }.store(in: &drawerCancellables)

        cancelButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    self?.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }

    private func previewItemAt(_ indexPath: IndexPath) {
        let item = sections[indexPath.section].elements[indexPath.item]
        guard let ftid = item.fileTransferId,
              item.status != .receiving,
              item.status != .receivingFailed else { return }

        let ft = viewModel.getFileTransferWith(id: ftid)
        fileURL = FileManager.url(for: "\(ft.name).\(ft.type)")
        coordinator.toPreview(from: self)
    }

    // MARK: Selectors

    @objc private func didTapDots() {
        coordinator.toMenuSheet(sheet, from: self)
    }

    @objc private func didTapInfo() {
        coordinator.toContact(viewModel.contact, from: self)
    }
}

extension SingleChatController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let sectionHeader: SectionHeaderView = collectionView.dequeueSupplementaryView(forIndexPath: indexPath)
        sectionHeader.title.text = sections[indexPath.section].model.date.asDayOfMonth()
        return sectionHeader
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        sections[section].elements.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let showRound: (String?) -> Void = viewModel.showRoundFrom(_:)
        let item = sections[indexPath.section].elements[indexPath.item]
        let replyContent: (Data) -> (String, String) = viewModel.getReplyContent(for:)
        let performReply: () -> Void = { [weak self] in self?.viewModel.didRequestReply(item) }

        let factory = CellFactory.combined(factories: [
            .incomingImage(transfer: viewModel.getFileTransferWith(id:)),
            .outgoingImage(transfer: viewModel.getFileTransferWith(id:)),
            .incomingAudio(voxophone: voxophone, transfer: viewModel.getFileTransferWith(id:)),
            .outgoingAudio(voxophone: voxophone, transfer: viewModel.getFileTransferWith(id:)),
            .incomingText(performReply: performReply, showRound: showRound),
            .outgoingText(performReply: performReply, showRound: showRound),
            .outgoingFailedText(performReply: performReply),
            .incomingReply(performReply: performReply, replyContent: replyContent, showRound: showRound),
            .outgoingReply(performReply: performReply, replyContent: replyContent, showRound: showRound),
            .outgoingFailedReply(performReply: performReply, replyContent: replyContent)
        ])

        return factory(item: item, collectionView: collectionView, indexPath: indexPath)
    }
}

extension SingleChatController: KeyboardListenerDelegate {
    fileprivate var isUserInitiatedScrolling: Bool {
        collectionView.isDragging || collectionView.isDecelerating
    }

    func keyboardWillChangeFrame(info: KeyboardInfo) {
        let keyWindow: UIWindow? = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: \.isKeyWindow)

        guard let keyWindow = keyWindow else {
            fatalError("[keyboardWillChangeFrame]: Couldn't get key window")
        }

        let keyboardFrame = keyWindow.convert(info.frameEnd, to: view)

        guard !currentInterfaceActions.options.contains(.changingFrameSize),
              collectionView.contentInsetAdjustmentBehavior != .never,
              collectionView.convert(collectionView.bounds, to: keyWindow).maxY > info.frameEnd.minY else { return }

        currentInterfaceActions.options.insert(.changingKeyboardFrame)
        let newBottomInset = collectionView.frame.minY + collectionView.frame.size.height - keyboardFrame.minY - collectionView.safeAreaInsets.bottom
        if newBottomInset > 0,
           collectionView.contentInset.bottom != newBottomInset {
            let positionSnapshot = chatLayout.getContentOffsetSnapshot(from: .bottom)

            currentInterfaceActions.options.insert(.changingContentInsets)
            UIView.animate(withDuration: info.animationDuration, animations: {
                self.collectionView.performBatchUpdates({
                    self.collectionView.contentInset.bottom = newBottomInset
                    self.collectionView.verticalScrollIndicatorInsets.bottom = newBottomInset
                }, completion: nil)

                if let positionSnapshot = positionSnapshot, !self.isUserInitiatedScrolling {
                    self.chatLayout.restoreContentOffset(with: positionSnapshot)
                }
            }, completion: { _ in
                self.currentInterfaceActions.options.remove(.changingContentInsets)
            })
        }
    }

    func keyboardDidChangeFrame(info: KeyboardInfo) {
        guard currentInterfaceActions.options.contains(.changingKeyboardFrame) else { return }
        currentInterfaceActions.options.remove(.changingKeyboardFrame)
    }
}

extension SingleChatController: UICollectionViewDelegate {
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String,
              let first = identifier.components(separatedBy: "|").first,
              let last = identifier.components(separatedBy: "|").last,
              let item = Int(first), let section = Int(last),
              let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) else {
                  return nil
              }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        let status = sections[section].elements[item].status

        if status == .received || status == .receiving {
            var leftView: UIView!

            if let cell = cell as? IncomingReplyCell {
                leftView = cell.leftView
            } else if let cell = cell as? IncomingAudioCell {
                leftView = cell.leftView
            } else if let cell = cell as? IncomingTextCell {
                leftView = cell.leftView
            } else if let cell = cell as? IncomingImageCell {
                leftView = cell.leftView
            }

            parameters.visiblePath = UIBezierPath(roundedRect: leftView.bounds, cornerRadius: 13)
            return UITargetedPreview(view: leftView, parameters: parameters)
        }

        #warning("TODO: Refactor")

        var rightView: UIView!

        if let cell = cell as? OutgoingTextCell {
            rightView = cell.rightView
        } else if let cell = cell as? OutgoingAudioCell {
            rightView = cell.rightView
        } else if let cell = cell as? OutgoingReplyCell {
            rightView = cell.rightView
        } else if let cell = cell as? OutgoingImageCell {
            rightView = cell.rightView
        } else if let cell = cell as? OutgoingFailedTextCell {
            rightView = cell.rightView
        } else if let cell = cell as? OutgoingFailedReplyCell {
            rightView = cell.rightView
        }

        parameters.visiblePath = UIBezierPath(roundedRect: rightView.bounds, cornerRadius: 13)
        return UITargetedPreview(view: rightView, parameters: parameters)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        makeTargetedPreview(for: configuration)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        makeTargetedPreview(for: configuration)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: "\(indexPath.item)|\(indexPath.section)" as NSCopying,
            previewProvider: nil
        ) { [weak self] _ in

            guard let self = self else { return nil }
            let item = self.sections[indexPath.section].elements[indexPath.item]

            return UIMenu(title: "", children: [
                ActionFactory.build(from: item, action: .copy, closure: self.viewModel.didRequestCopy(_:)),
                ActionFactory.build(from: item, action: .retry, closure: self.viewModel.didRequestRetry(_:)),
                ActionFactory.build(from: item, action: .reply, closure: self.viewModel.didRequestReply(_:)),
                ActionFactory.build(from: item, action: .delete, closure: self.viewModel.didRequestDeleteSingle(_:)),
                ActionFactory.build(from: item, action: .report, closure: self.viewModel.didRequestReport(_:))
            ].compactMap { $0 })
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        previewItemAt(indexPath)
    }
}

extension SingleChatController: UIImagePickerControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.delegate = nil
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }

        DispatchQueue.global().async { [weak self] in
            self?.viewModel.didSend(image: image)
        }
    }
}

extension SingleChatController: UINavigationControllerDelegate {}

extension SingleChatController: QLPreviewControllerDataSource {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        fileURL! as QLPreviewItem
    }
}

extension SingleChatController: QLPreviewControllerDelegate {
    public func previewControllerDidDismiss(_ controller: QLPreviewController) {
        fileURL = nil
    }
}
