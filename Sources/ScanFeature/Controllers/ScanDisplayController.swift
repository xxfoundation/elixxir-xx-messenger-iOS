import UIKit
import Combine

final class ScanDisplayController: UIViewController {
    private lazy var screenView = ScanDisplayView()

    private let viewModel = ScanDisplayViewModel()
    private var cancellables = Set<AnyCancellable>()

    var didTapInfo: (() -> Void)?
    var didTapAddPhone: (() -> Void)?
    var didTapAddEmail: (() -> Void)?

    override func loadView() {
        view = screenView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.loadCached()
        viewModel.generateQR()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                if let image = $0.image {
                    screenView.setup(code: image)
                }

                screenView.setupAttributes(
                    email: $0.email,
                    phone: $0.phone,
                    emailSharing: $0.isSharingEmail,
                    phoneSharing: $0.isSharingPhone
                )
            }.store(in: &cancellables)

        screenView.actionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                switch $0 {
                case .info:
                    didTapInfo?()

                case .addEmail:
                    didTapAddEmail?()

                case .addPhone:
                    didTapAddPhone?()

                case .toggleEmail:
                    viewModel.didToggleEmail()

                case .togglePhone:
                    viewModel.didTogglePhone()
                }
            }.store(in: &cancellables)

        viewModel.loadCached()
        viewModel.generateQR()
    }
}
