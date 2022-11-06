import UIKit
import Combine
import DependencyInjection

final class RequestsSentController: UIViewController {
    var connectionsPublisher: AnyPublisher<Void, Never> {
        connectionSubject.eraseToAnyPublisher()
    }

    private lazy var screenView = RequestsSentView()
    private let viewModel = RequestsSentViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let tapSubject = PassthroughSubject<Request, Never>()
    private let connectionSubject = PassthroughSubject<Void, Never>()
    private var dataSource: UICollectionViewDiffableDataSource<Section, RequestSent>?

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        screenView.collectionView.register(RequestCell.self)
        dataSource = UICollectionViewDiffableDataSource<Section, RequestSent>(
            collectionView: screenView.collectionView
        ) { collectionView, indexPath, requestSent in

            let cell: RequestCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.setupFor(requestSent: requestSent)
            cell.didTapStateButton = { [weak self] in
                guard let self = self else { return }
                self.viewModel.didTapStateButtonFor(request: requestSent)
            }
            return cell
        }

        viewModel.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dataSource?.apply($0, animatingDifferences: false)
                screenView.collectionView.isHidden = $0.numberOfItems == 0
            }.store(in: &cancellables)

        screenView.connectionsButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in connectionSubject.send() }
            .store(in: &cancellables)
    }
}
