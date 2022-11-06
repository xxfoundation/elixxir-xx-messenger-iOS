import UIKit
import Combine

final class SheetController: UIViewController {
    enum Action {
        case clear
        case details
        case report
    }

    private lazy var screenView = SheetView()

    var actionPublisher: AnyPublisher<Action, Never> {
        actionRelay.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let actionRelay = PassthroughSubject<Action, Never>()

    public override func loadView() {
        view = screenView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        screenView.clearButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak actionRelay] in
                    actionRelay?.send(.clear)
                }
            }.store(in: &cancellables)

        screenView.detailsButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak actionRelay] in
                    actionRelay?.send(.details)
                }
            }.store(in: &cancellables)

        screenView.reportButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak actionRelay] in
                    actionRelay?.send(.report)
                }
            }.store(in: &cancellables)
    }
}
