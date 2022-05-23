import UIKit
import Combine
import Models

final class SearchTableController: UITableViewController {
    // MARK: Properties

    private let viewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()
    private(set) var dataSource = [Contact]()

    // MARK: Lifecycle

    init(_ viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBindings()
    }

    // MARK: Private

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(SearchCell.self)
    }

    private func setupBindings() {
        viewModel
            .itemsRelay
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dataSource = $0
                tableView.reloadData()
            }.store(in: &cancellables)
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, ofType: SearchCell.self)
        cell.title.text = dataSource[indexPath.row].username
        cell.subtitle.text = dataSource[indexPath.row].username
        cell.avatar.setupProfile(title: dataSource[indexPath.row].username, image: nil, size: .large)
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int { dataSource.count }
}

