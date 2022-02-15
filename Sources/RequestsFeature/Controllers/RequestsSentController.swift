import HUD
import UIKit
import Models
import Shared
import Combine
import DifferenceKit

final class RequestsSentController: UITableViewController {
    lazy private(set) var emptyView = UIView()

    var tapPublisher: AnyPublisher<Contact, Never> {
        tapRelay.eraseToAnyPublisher()
    }

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudRelay.eraseToAnyPublisher()
    }

    var emptyTapPublisher: AnyPublisher<Void, Never> {
        emptyTapRelay.eraseToAnyPublisher()
    }

    private var items = [Contact]()
    private let viewModel = RequestsSentViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let tapRelay = PassthroughSubject<Contact, Never>()
    private let emptyTapRelay = PassthroughSubject<Void, Never>()
    private let hudRelay = PassthroughSubject<HUDStatus, Never>()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyView.frame = view.frame
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupEmptyState()
        setupBindings()
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(RequestSentCell.self)
        tableView.backgroundColor = Asset.neutralWhite.color
        tableView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)
    }

    private func setupEmptyState() {
        let icon = UIImageView()
        icon.contentMode = .center
        icon.image = Asset.requestsReceivedPlaceholder.image

        let button = CapsuleButton()
        button.setStyle(.brandColored)
        button.setTitle(Localized.Requests.Sent.action, for: .normal)

        button.publisher(for: .touchUpInside)
            .sink { [weak emptyTapRelay] in emptyTapRelay?.send() }
            .store(in: &cancellables)

        let stack = UIStackView()
        stack.spacing = 24
        stack.axis = .vertical
        stack.alignment = .center
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(button)

        emptyView.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
    }

    private func setupBindings() {
        viewModel.items
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                let changeSet = StagedChangeset(source: self.items, target: $0)

                self.tableView.reload(
                    using: changeSet,
                    deleteSectionsAnimation: .none,
                    insertSectionsAnimation: .none,
                    reloadSectionsAnimation: .none,
                    deleteRowsAnimation: .none,
                    insertRowsAnimation: .none,
                    reloadRowsAnimation: .none
                ) { [unowned self] in
                    self.items = $0
                }
            }.store(in: &cancellables)

        viewModel.items
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in emptyView.isHidden = !$0.isEmpty }
            .store(in: &cancellables)

        viewModel.hud
            .sink { [weak hudRelay] in hudRelay?.send($0) }
            .store(in: &cancellables)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RequestSentCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let contact = items[indexPath.row]

        cell.setup(
            username: contact.username,
            nickname: contact.nickname,
            createdAt: contact.createdAt,
            photo: contact.photo
        )

        cell.button
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapResend(contact) }
            .store(in: &cell.cancellables)

        return cell
    }

    override func tableView(_: UITableView, numberOfRowsInSection: Int) -> Int {
        items.count
    }

    override func tableView(_: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        56
    }
}
