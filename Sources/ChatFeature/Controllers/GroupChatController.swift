import HUD
import UIKit
import Theme
import Models
import Shared
import Combine
import XXModels
import Voxophone
import ChatLayout
import Integration
import DrawerFeature
import DifferenceKit
import ReportingFeature
import ChatInputFeature
import DependencyInjection

typealias OutgoingGroupTextCell = CollectionCell<FlexibleSpace, StackMessageView>
typealias IncomingGroupTextCell = CollectionCell<StackMessageView, FlexibleSpace>
typealias OutgoingGroupReplyCell = CollectionCell<FlexibleSpace, ReplyStackMessageView>
typealias IncomingGroupReplyCell = CollectionCell<ReplyStackMessageView, FlexibleSpace>
typealias OutgoingFailedGroupTextCell = CollectionCell<FlexibleSpace, StackMessageView>
typealias OutgoingFailedGroupReplyCell = CollectionCell<FlexibleSpace, ReplyStackMessageView>

public final class GroupChatController: UIViewController {
    @Dependency private var hud: HUD
    @Dependency private var session: SessionType
    @Dependency private var coordinator: ChatCoordinating
    @Dependency private var makeReportDrawer: MakeReportDrawer
    @Dependency private var makeAppScreenshot: MakeAppScreenshot
    @Dependency private var statusBarController: StatusBarStyleControlling

    private let members: MembersController
    private var collectionView: UICollectionView!
    lazy private var header = GroupHeaderView()
    private let inputComponent: ChatInputView

    private let chatLayout = ChatLayout()
    private var animator: ManualAnimator?
    private let viewModel: GroupChatViewModel
    private let layoutDelegate = LayoutDelegate()
    private var cancellables = Set<AnyCancellable>()
    private var sections = [ArraySection<ChatSection, Message>]()
    private var currentInterfaceActions = SetActor<Set<InterfaceActions>, ReactionTypes>()

    public override var canBecomeFirstResponder: Bool { true }
    public override var inputAccessoryView: UIView? { inputComponent }

    public init(_ info: GroupInfo) {
        let viewModel = GroupChatViewModel(info)
        self.viewModel = viewModel
        self.members = .init(with: info.members)

        self.inputComponent = ChatInputView(store: .init(
            initialState: .init(canAddAttachments: false),
            reducer: chatInputReducer,
            environment: .init(
                voxophone: try! DependencyInjection.Container.shared.resolve() as Voxophone,
                sendAudio: { _ in },
                didTapCamera: {},
                didTapLibrary: {},
                sendText: { viewModel.send($0) },
                didTapAbortReply: { viewModel.abortReply() },
                didTapMicrophone: { false }
            )
        ))

        super.init(nibName: nil, bundle: nil)

        let memberList = info.members.map {
            Member(
                title: ($0.nickname ?? $0.username) ?? "Fetching username...",
                photo: $0.photo
            )
        }

        header.setup(title: info.group.name, memberList: memberList)
    }

    public required init?(coder: NSCoder) { nil }

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

        setupNavigationBar()
        setupCollectionView()
        setupInputController()
        setupBindings()

        KeyboardListener.shared.add(delegate: self)
    }

    private func setupNavigationBar() {
        let more = UIButton()
        more.setImage(Asset.chatMore.image, for: .normal)
        more.addTarget(self, action: #selector(didTapDots), for: .touchUpInside)

        navigationItem.titleView = header
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: more)
    }

    private func setupCollectionView() {
        chatLayout.configure(layoutDelegate)
        collectionView = .init(on: view, with: chatLayout)
        collectionView.register(IncomingGroupTextCell.self)
        collectionView.register(OutgoingGroupTextCell.self)
        collectionView.register(IncomingGroupReplyCell.self)
        collectionView.register(OutgoingGroupReplyCell.self)
        collectionView.register(OutgoingFailedGroupTextCell.self)
        collectionView.register(OutgoingFailedGroupReplyCell.self)
        collectionView.registerSectionHeader(SectionHeaderView.self)
        collectionView.dataSource = self
        collectionView.delegate = self
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
    }

    private func setupBindings() {
        viewModel.routesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                switch $0 {
                case .waitingRound:
                    coordinator.toDrawer(makeWaitingRoundDrawer(), from: self)
                case .webview(let urlString):
                    coordinator.toWebview(with: urlString, from: self)
                }
            }.store(in: &cancellables)

        viewModel.hudPublisher
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        viewModel.reportPopupPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] contact in
                presentReportDrawer(contact)
            }.store(in: &cancellables)

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

    @objc private func didTapDots() {
        coordinator.toMembersList(members, from: self)
    }

    private func presentReportDrawer(_ contact: Contact) {
        var config = MakeReportDrawer.Config()
        config.onReport = { [weak self] in
            guard let self = self else { return }
            let screenshot = try! self.makeAppScreenshot()
            self.viewModel.report(contact: contact, screenshot: screenshot) {
                self.collectionView.reloadData()
            }
        }
        let drawer = makeReportDrawer(config)
        coordinator.toDrawer(drawer, from: self)
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
                drawer?.dismiss(animated: true)
            }.store(in: &drawer.cancellables)

        return drawer
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
}

extension GroupChatController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader: SectionHeaderView = collectionView.dequeueSupplementaryView(forIndexPath: indexPath)
        sectionHeader.title.text = sections[indexPath.section].model.date.asDayOfMonth()
        return sectionHeader
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].elements.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        var item = sections[indexPath.section].elements[indexPath.item]
        let canReply: () -> Bool = {
            (item.status == .sent || item.status == .received) && item.networkId != nil
        }

        let performReply: () -> Void = { [weak self] in
            self?.viewModel.didRequestReply(item)
        }

        let name: (Data) -> String = viewModel.getName(from:)
        let showRound: (String?) -> Void = viewModel.showRoundFrom(_:)
        let replyContent: (Data) -> (String, String) = viewModel.getReplyContent(for:)

        var isSenderBanned = false

        if let sender = try? session.dbManager.fetchContacts(.init(id: [item.senderId])).first {
            isSenderBanned = sender.isBanned
        }

        if item.status == .received {
            guard isSenderBanned == false else {
                item.text = "This user has been banned"

                let cell: IncomingGroupTextCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                Bubbler.buildGroup(
                    bubble: cell.leftView,
                    with: item,
                    with: "Banned user"
                )

                cell.canReply = false
                cell.performReply = {}
                cell.leftView.didTapShowRound = {}

                return cell
            }

            if let replyMessageId = item.replyMessageId {
                let cell: IncomingGroupReplyCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.buildReplyGroup(
                    bubble: cell.leftView,
                    with: item,
                    reply: replyContent(replyMessageId),
                    sender: name(item.senderId)
                )

                cell.canReply = canReply()
                cell.performReply = performReply
                cell.leftView.didTapShowRound = { showRound(item.roundURL) }

                return cell
            } else {
                let cell: IncomingGroupTextCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                Bubbler.buildGroup(
                    bubble: cell.leftView,
                    with: item,
                    with: name(item.senderId)
                )

                cell.canReply = canReply()
                cell.performReply = performReply
                cell.leftView.didTapShowRound = { showRound(item.roundURL) }

                return cell
            }
        } else if item.status == .sendingFailed {
            if let replyMessageId = item.replyMessageId {
                let cell: OutgoingFailedGroupReplyCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.buildReplyGroup(
                    bubble: cell.rightView,
                    with: item,
                    reply: replyContent(replyMessageId),
                    sender: name(item.senderId)
                )

                cell.canReply = canReply()
                cell.performReply = performReply

                return cell
            } else {
                let cell: OutgoingFailedGroupTextCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.buildGroup(
                    bubble: cell.rightView,
                    with: item,
                    with: name(item.senderId)
                )

                cell.canReply = canReply()
                cell.performReply = performReply

                return cell
            }
        } else {
            if let replyMessageId = item.replyMessageId {
                let cell: OutgoingGroupReplyCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.buildReplyGroup(
                    bubble: cell.rightView,
                    with: item,
                    reply: replyContent(replyMessageId),
                    sender: name(item.senderId)
                )

                cell.canReply = canReply()
                cell.performReply = performReply
                cell.rightView.didTapShowRound = { showRound(item.roundURL) }

                return cell
            } else {
                let cell: OutgoingGroupTextCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.buildGroup(
                    bubble: cell.rightView,
                    with: item,
                    with: name(item.senderId)
                )

                cell.canReply = canReply()
                cell.performReply = performReply
                cell.rightView.didTapShowRound = { showRound(item.roundURL) }

                return cell
            }
        }
    }
}

extension GroupChatController: KeyboardListenerDelegate {
    fileprivate var isUserInitiatedScrolling: Bool {
        return collectionView.isDragging || collectionView.isDecelerating
    }

    func keyboardWillChangeFrame(info: KeyboardInfo) {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

        guard !currentInterfaceActions.options.contains(.changingFrameSize),
              collectionView.contentInsetAdjustmentBehavior != .never,
              let keyboardFrame = keyWindow?.convert(info.frameEnd, to: view),
              collectionView.convert(collectionView.bounds, to: keyWindow).maxY > info.frameEnd.minY else {
                  return
              }
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

extension GroupChatController: UICollectionViewDelegate {
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

        if sections[section].elements[item].status == .received {
            var leftView: UIView!

            if let cell = cell as? IncomingGroupReplyCell {
                leftView = cell.leftView
            } else if let cell = cell as? IncomingGroupTextCell {
                leftView = cell.leftView
            }

            parameters.visiblePath = UIBezierPath(roundedRect: leftView.bounds, cornerRadius: 13)
            return UITargetedPreview(view: leftView, parameters: parameters)
        }

        var rightView: UIView!

        if let cell = cell as? OutgoingGroupTextCell {
            rightView = cell.rightView
        } else if let cell = cell as? OutgoingGroupReplyCell {
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
        ) { [weak self] suggestedActions in

            guard let self = self else { return nil }

            let item = self.sections[indexPath.section].elements[indexPath.item]

            let copy = UIAction(title: Localized.Chat.BubbleMenu.copy, state: .off) { _ in
                UIPasteboard.general.string = item.text
            }

            let reply = UIAction(title: Localized.Chat.BubbleMenu.reply, state: .off) { [weak self] _ in
                self?.viewModel.didRequestReply(item)
            }

            let delete = UIAction(title: Localized.Chat.BubbleMenu.delete, state: .off) { [weak self] _ in
                self?.viewModel.didRequestDelete([item])
            }

            let report = UIAction(title: Localized.Chat.BubbleMenu.report, state: .off) { [weak self] _ in
                self?.viewModel.didRequestReport(item)
            }

            let retry = UIAction(title: Localized.Chat.BubbleMenu.retry, state: .off) { [weak self] _ in
                self?.viewModel.retry(item)
            }

            var children = [UIAction]()

            if item.status == .sendingFailed {
                children = [copy, retry, delete]
            } else if item.status == .sending {
                children = [copy]
            } else {
                children = [copy, reply, delete]

                if self.viewModel.isReportingEnabled {
                    children.append(report)
                }
            }

            return UIMenu(title: "", children: children)
        }
    }
}
