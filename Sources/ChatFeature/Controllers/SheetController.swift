import UIKit
import Combine

final class SheetController: UIViewController {
    enum Action {
        case clear
        case details
    }

    lazy private var screenView = SheetView()

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

        screenView.clear
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak actionRelay] in
                    actionRelay?.send(.clear)
                }
            }.store(in: &cancellables)

        screenView.details
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                dismiss(animated: true) { [weak actionRelay] in
                    actionRelay?.send(.details)
                }
            }.store(in: &cancellables)
    }
}
