import Combine
import DI

enum BackupViewState: Equatable {
    case setup
    case config
}

struct BackupViewModel {
    var setupViewModel: () -> BackupSetupViewModel
    var configViewModel: () -> BackupConfigViewModel

    var state: () -> AnyPublisher<BackupViewState, Never>
}

extension BackupViewModel {
    static func live() -> Self {
        class Context {
            @Dependency var service: BackupService
        }

        let context = Context()

        return .init(
            setupViewModel: { BackupSetupViewModel.live() },
            configViewModel: { BackupConfigViewModel.live() },
            state: {
                context.service.connectedServicesPublisher
                    .map { $0.isEmpty ? BackupViewState.setup : .config }
                    .eraseToAnyPublisher()
            }
        )
    }
}
