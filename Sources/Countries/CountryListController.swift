import Theme
import UIKit
import Shared
import Combine
import CollectionView
import DependencyInjection

public final class CountryListController: UIViewController {
    @Dependency var statusBarController: StatusBarStyleControlling
    
    lazy private var screenView = CountryListView()

    private var didChoose: ((Country) -> Void)!
    private let viewModel = CountryListViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UICollectionViewDiffableDataSource<Int, Country>!

    public init(_ didChoose: @escaping (Country) -> Void) {
        self.didChoose = didChoose
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

    public override func loadView() {
        view = screenView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        setupBindings()
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = " "

        let titleLabel = UILabel()
        titleLabel.text = Localized.Countries.title
        titleLabel.textColor = Asset.neutralActive.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let backButton = UIButton.back()
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [backButton, titleLabel])
        )
    }

    private func setupBindings() {
        viewModel.countriesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in dataSource.apply($0, animatingDifferences: false) }
            .store(in: &cancellables)

        screenView.searchComponent
            .textPublisher
            .removeDuplicates()
            .sink { [unowned self] in viewModel.didSearchFor($0) }
            .store(in: &cancellables)
    }

    private func setupCollectionView() {
        CellFactory.countryListCellFactory
            .register(in: screenView.collectionView)

        dataSource = UICollectionViewDiffableDataSource<Int, Country>(
            collectionView: screenView.collectionView
        ) { collectionView, indexPath, country in
            CellFactory.countryListCellFactory.build(for: country, in: collectionView, at: indexPath)
        }

        screenView.collectionView.delegate = self
        screenView.collectionView.dataSource = dataSource
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension CountryListController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let country = dataSource.itemIdentifier(for: indexPath) {
            didChoose(country)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension CellFactory where Model == Country {
    static let countryListCellFactory = Self.init(
        register: .init { $0.register(CountryListCell.self) },
        build: .init { country, collectionView, indexPath in
            let cell: CountryListCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

            cell.set(
                flag: country.flag,
                name: country.name,
                prefix: country.prefix
            )

            return cell
        }
    )
}
