import UIKit
import Combine

public final class RetrySheetController: UIViewController {
    enum Action {
        case retry
        case delete
        case cancel
    }

    // MARK: UI

    lazy private var screenView = RetrySheetView()

    // MARK: Properties

    var actionPublisher: AnyPublisher<Action, Never> {
        actionRelay.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let actionRelay = PassthroughSubject<Action, Never>()

    // MARK: Lifecycle

    public override func loadView() {
        view = screenView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    // MARK: Private

    private func setupBindings() {
        screenView.retry
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak actionRelay] in
                    actionRelay?.send(.retry)
                }
            }.store(in: &cancellables)

        screenView.delete
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak actionRelay] in
                    actionRelay?.send(.delete)
                }
            }.store(in: &cancellables)

        screenView.cancel
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak actionRelay] in
                    actionRelay?.send(.cancel)
                }
            }.store(in: &cancellables)
    }
}
