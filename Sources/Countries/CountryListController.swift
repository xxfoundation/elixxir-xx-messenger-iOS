import os
import UIKit
import Shared
import Combine
import DependencyInjection

public final class CountryListController: UIViewController {
  @Dependency var barStylist: StatusBarStylist

  lazy private var screenView = CountryListView()

  private var didChoose: ((Country) -> Void)!
  private let viewModel = CountryListViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var dataSource: UITableViewDiffableDataSource<SectionId, Country>!

  public init(_ didChoose: @escaping (Country) -> Void) {
    self.didChoose = didChoose
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    barStylist.styleSubject.send(.darkContent)

    navigationController?.navigationBar.customize(
      backgroundColor: Asset.neutralWhite.color,
      shadowColor: Asset.neutralDisabled.color
    )
  }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    screenView.tableView.register(CountryListCell.self)
    setupNavigationBar()
    setupBindings()

    viewModel.fetchCountryList()
  }

  private func setupNavigationBar() {
    let title = UILabel()
    title.text = Localized.Countries.title
    title.textColor = Asset.neutralActive.color
    title.font = Fonts.Mulish.semiBold.font(size: 18.0)

    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: title)
    navigationItem.leftItemsSupplementBackButton = true
  }

  private func setupBindings() {
    viewModel.countries
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in dataSource.apply($0, animatingDifferences: false) }
      .store(in: &cancellables)

    dataSource = UITableViewDiffableDataSource<SectionId, Country>(
      tableView: screenView.tableView
    ) { tableView, indexPath, country in
      let cell: CountryListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.flagLabel.text = country.flag
      cell.nameLabel.text = country.name
      cell.prefixLabel.text = country.prefix
      return cell
    }

    screenView.searchComponent
      .textPublisher
      .removeDuplicates()
      .sink { [unowned self] in viewModel.didSearchFor($0) }
      .store(in: &cancellables)

    screenView.tableView.delegate = self
    screenView.tableView.dataSource = dataSource
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let country = dataSource.itemIdentifier(for: indexPath) {
      didChoose(country)
      navigationController?.popViewController(animated: true)
    }
  }
}

extension CountryListController: UITableViewDelegate {}
