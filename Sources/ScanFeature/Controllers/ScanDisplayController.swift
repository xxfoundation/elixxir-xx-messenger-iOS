import UIKit
import Combine
import Countries

final class ScanDisplayController: UIViewController {
    lazy private var screenView = ScanDisplayView()

    private let viewModel = ScanDisplayViewModel()
    private var cancellables = Set<AnyCancellable>()

    var didTapInfo: (() -> Void)?

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.state
            .map(\.image)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                guard let ciimage = $0 else { return }
                screenView.qrImage.image = UIImage(ciImage: ciimage)
            }.store(in: &cancellables)

        if viewModel.email != nil || viewModel.phone != nil {
            screenView.setupShareView { [weak self] in self?.didTapInfo?() }

            if let email = viewModel.email {
                screenView.shareView.setup(email: email)
                    .sink { [unowned self] in viewModel.didToggleEmail() }
                    .store(in: &cancellables)

                viewModel.state.map(\.isSharingEmail)
                    .removeDuplicates()
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] in screenView.shareView.emailView.switcherView.setOn($0, animated: false) }
                    .store(in: &cancellables)
            }

            if let phone = viewModel.phone {
                let fullPhone = "\(Country.findFrom(phone).prefix)\(phone.dropLast(2))"

                screenView.shareView.setup(phone: fullPhone)
                    .sink { [unowned self] in viewModel.didTogglePhone() }
                    .store(in: &cancellables)

                viewModel.state.map(\.isSharingPhone)
                    .removeDuplicates()
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] in screenView.shareView.phoneView.switcherView.setOn($0, animated: false) }
                    .store(in: &cancellables)
            }
        }

        viewModel.loadCached()
        viewModel.generateQR()
    }
}
