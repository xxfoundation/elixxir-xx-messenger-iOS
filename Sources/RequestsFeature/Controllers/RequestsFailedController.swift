import HUD
import UIKit
import Shared
import Combine
import Models
import DifferenceKit

final class RequestsFailedController: UITableViewController {
    // MARK: Properties

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudRelay.eraseToAnyPublisher()
    }

    var didTap: AnyPublisher<Contact, Never> {
        tapRelay.eraseToAnyPublisher()
    }

    private let tapRelay = PassthroughSubject<Contact, Never>()
    private let hudRelay = PassthroughSubject<HUDStatus, Never>()

    private var items = [Contact]()
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = RequestsFailedViewModel()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBindings()
    }

    // MARK: Private

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(RequestFailedCell.self)
        tableView.backgroundColor = Asset.neutralWhite.color
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

        viewModel.hud
            .sink { [weak hudRelay] in hudRelay?.send($0) }
            .store(in: &cancellables)
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RequestFailedCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let contact = items[indexPath.row]

        cell.setup(
            username: contact.username,
            nickname: contact.nickname,
            createdAt: contact.createdAt,
            photo: contact.photo
        )

        cell.button
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapRetry(contact) }
            .store(in: &cell.cancellables)

        return cell
    }

    // MARK: UITableViewDelegate

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tapRelay.send(items[indexPath.row])
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { items.count }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat { 72 }
}
