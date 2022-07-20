import UIKit
import Combine
import DependencyInjection

final class SearchRightController: UIViewController {
    @Dependency var coordinator: SearchCoordinating

    lazy private var screenView = SearchRightView()

    private var cancellables = Set<AnyCancellable>()
    private let cameraController = CameraController()
    private(set) var viewModel = SearchRightViewModel()

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        screenView.layer.insertSublayer(cameraController.previewLayer, at: 0)
        setupBindings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraController.previewLayer.frame = screenView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear()
    }

    private func setupBindings() {
        cameraController
            .dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in viewModel.didScan(data: $0) }
            .store(in: &cancellables)

        viewModel.cameraSemaphorePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.global())
            .sink { [unowned self] setOn in
                if setOn {
                    cameraController.start()
                } else {
                    cameraController.stop()
                }
            }.store(in: &cancellables)

        viewModel.foundPublisher
            .receive(on: DispatchQueue.main)
            .delay(for: 1, scheduler: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toContact($0, from: self) }
            .store(in: &cancellables)

        viewModel.statusPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [unowned self] in screenView.update(status: $0) }
            .store(in: &cancellables)

        screenView.actionButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                switch viewModel.statusSubject.value {
                case .failed(.cameraPermission):
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url, options: [:])
                case .failed(.requestOpened):
                    coordinator.toRequests(from: self)
                case .failed(.alreadyFriends):
                    coordinator.toContacts(from: self)
                default:
                    break
                }
            }.store(in: &cancellables)
    }
}
