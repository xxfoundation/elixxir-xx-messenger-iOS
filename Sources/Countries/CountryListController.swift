import os
import Theme
import UIKit
import Shared
import Combine
import DependencyInjection

private let logger = Logger(subsystem: "logs_xxmessenger", category: "Countries.CountryListController.swift")

public final class CountryListController: UIViewController {
    @Dependency private var statusBarController: StatusBarStyleControlling
    
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
        logger.log("viewWillAppear()")

        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)

        navigationController?.navigationBar.customize(
            backgroundColor: Asset.neutralWhite.color,
            shadowColor: Asset.neutralDisabled.color
        )
    }

    public override func loadView() {
        logger.log("loadView()")
        view = screenView
    }

    public override func viewDidLoad() {
        logger.log("viewDidLoad()")

        super.viewDidLoad()
        screenView.tableView.register(CountryListCell.self)
        setupNavigationBar()
        setupBindings()

        viewModel.fetchCountryList()
    }
    
    private func setupNavigationBar() {
        logger.log("setupNavigationBar()")

        navigationItem.backButtonTitle = " "

        let title = UILabel()
        title.text = Localized.Countries.title
        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back, title])
        )
    }

    private func setupBindings() {
        logger.log("setupBindings()")

        viewModel.countries
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in dataSource.apply($0, animatingDifferences: false) }
            .store(in: &cancellables)

        dataSource = UITableViewDiffableDataSource<SectionId, Country>(
            tableView: screenView.tableView
        ) { tableView, indexPath, country in
            let cell: CountryListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.flag.text = country.flag
            cell.name.text = country.name
            cell.prefix.text = country.prefix
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
    
    @objc private func didTapBack() {
        logger.log("didTapBack()")
        navigationController?.popViewController(animated: true)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logger.log("tableView(didSelectRowAt indexPath.row: \(indexPath.row, privacy: .public)()")

        if let country = dataSource.itemIdentifier(for: indexPath) {
            didChoose(country)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension CountryListController: UITableViewDelegate {}
