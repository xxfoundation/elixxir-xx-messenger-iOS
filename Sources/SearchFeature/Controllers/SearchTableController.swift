import UIKit
import Models
import Combine
import XXModels

final class SearchTableController: UITableViewController {
    private let viewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()
    private(set) var dataSource = [Contact]()

    init(_ viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(SearchCell.self)

        viewModel.itemsRelay
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dataSource = $0
                tableView.reloadData()
            }.store(in: &cancellables)
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, ofType: SearchCell.self)
        let username = dataSource[indexPath.row].username!

        cell.setup(
            title: username,
            subtitle: username,
            avatarTitle: username,
            avatarImage: nil,
            avatarSize: .large
        )

        return cell
    }

    override func tableView(
        _: UITableView,
        numberOfRowsInSection: Int
    ) -> Int { dataSource.count }
}

