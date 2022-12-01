import UIKit
import Shared
import Combine
import AppCore
import AppResources
import Dependencies

public final class CountryListController: UIViewController, UITableViewDelegate {
  @Dependency(\.app.statusBar) var statusBar

  private lazy var screenView = CountryListView()

  private let completion: (Country) -> Void
  private let viewModel = CountryListViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var dataSource: UITableViewDiffableDataSource<SectionId, Country>!

  public init(_ completion: @escaping (Country) -> Void) {
    self.completion = completion
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    statusBar.set(.darkContent)
  }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    screenView
      .tableView
      .register(CountryListCell.self)

    viewModel
      .countries
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dataSource.apply($0, animatingDifferences: false)
      }.store(in: &cancellables)

    dataSource = UITableViewDiffableDataSource<SectionId, Country>(
      tableView: screenView.tableView
    ) { tableView, indexPath, country in
      let cell: CountryListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.flagLabel.text = country.flag
      cell.nameLabel.text = country.name
      cell.prefixLabel.text = country.prefix
      return cell
    }

    screenView
      .searchComponent
      .textPublisher
      .removeDuplicates()
      .sink { [unowned self] in
        viewModel.didSearchFor($0)
      }.store(in: &cancellables)

    screenView.tableView.delegate = self
    screenView.tableView.dataSource = dataSource
    viewModel.fetchCountryList()
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let country = dataSource.itemIdentifier(for: indexPath) {
      completion(country)
      dismiss(animated: true)
    }
  }
}
