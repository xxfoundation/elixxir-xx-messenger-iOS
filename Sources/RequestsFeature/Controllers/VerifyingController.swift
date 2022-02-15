import UIKit
import Combine

final class VerifyingController: UIViewController {
    lazy private var screenView = VerifyingView()

    private var cancellables = Set<AnyCancellable>()

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        screenView.action.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in dismiss(animated: true) }
            .store(in: &cancellables)
    }
}
