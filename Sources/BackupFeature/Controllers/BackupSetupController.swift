import UIKit
import Models
import Combine
import DependencyInjection

final class BackupSetupController: UIViewController {
    lazy private var screenView = BackupSetupView()

    private let viewModel: BackupSetupViewModel
    private var cancellables = Set<AnyCancellable>()

    override func loadView() {
        view = screenView
    }

    init(_ viewModel: BackupSetupViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        screenView.googleDriveButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapService(.drive, self) }
            .store(in: &cancellables)

        screenView.dropboxButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapService(.dropbox, self) }
            .store(in: &cancellables)

        screenView.iCloudButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapService(.icloud, self) }
            .store(in: &cancellables)

        screenView.sftpButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in viewModel.didTapService(.sftp, self) }
            .store(in: &cancellables)
    }
}
