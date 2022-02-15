import HUD
import UIKit
import Shared
import Combine
import DependencyInjection

final class RequestsReceivedController: UITableViewController {
    @Dependency private var coordinator: RequestsCoordinating

    lazy private(set) var emptyView = RequestReceivedEmptyView()

    var hudPublisher: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    var tapPublisher: AnyPublisher<RequestReceived, Never> { tapRelay.eraseToAnyPublisher() }
    var verifyingPublisher: AnyPublisher<Void, Never> { verifyingRelay.eraseToAnyPublisher() }

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = RequestsReceivedViewModel()
    private var dataSource: UITableViewDiffableDataSource<SectionId, RequestReceived>!

    private let verifyingRelay = PassthroughSubject<Void, Never>()
    private let hudRelay = PassthroughSubject<HUDStatus, Never>()
    private let tapRelay = PassthroughSubject<RequestReceived, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.register(RequestReceivedCell.self)
        tableView.backgroundColor = Asset.neutralWhite.color
        tableView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)

        setupBindings()
    }

    private func setupBindings() {
        viewModel.hud
            .sink { [weak hudRelay] in hudRelay?.send($0) }
            .store(in: &cancellables)

        dataSource = UITableViewDiffableDataSource<SectionId, RequestReceived>(
            tableView: tableView
        ) { tableView, indexPath, request in
            let cell: RequestReceivedCell = tableView.dequeueReusableCell(forIndexPath: indexPath)

            let isGroup = request.group != nil
            let possibleContactTitle = request.contact?.nickname ?? request.contact?.username

            let title = isGroup ? request.group!.name : possibleContactTitle
            let createdAt = request.contact?.createdAt ?? Date()
            var actionsHidden: Bool

            if isGroup {
                actionsHidden = false
            } else {
                actionsHidden = request.contact!.status != .verified
            }

            cell.setup(
                name: title ?? "",
                createdAt: createdAt,
                photo: request.contact?.photo,
                actionsHidden: actionsHidden,
                verificationFailed: request.contact?.status == .verificationFailed
            )

            cell.didTapAccept = { [weak self] in
                guard let self = self else { return }

                guard let group = request.group else {
                    self.coordinator.toNickname(from: self, prefilled: possibleContactTitle ?? "") {
                        var contact = request.contact!
                        contact.nickname = $0
                        self.viewModel.didAccept(contact)
                    }
                    return
                }

                self.viewModel.didAccept(group)
            }

            cell.didTapReject = { [weak self] in
                guard let self = self else { return }
                self.viewModel.didTapReject(request)
            }

            cell.didTapVerification = { [weak self] in
                guard let self = self, let contact = request.contact else { return }

                if contact.status == .verificationInProgress {
                    self.verifyingRelay.send()
                } else if contact.status == .verificationFailed {
                    self.viewModel.didTapVerification(contact)
                }
            }

            return cell
        }

        viewModel.requests
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                emptyView.isHidden = !$0.itemIdentifiers.isEmpty
                dataSource.apply($0, animatingDifferences: false)
            }.store(in: &cancellables)
    }

    // MARK: UITableViewDelegate

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let request = dataSource.itemIdentifier(for: indexPath) {
            tapRelay.send(request)
        }
    }

    override func tableView(_: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        72
    }
}
