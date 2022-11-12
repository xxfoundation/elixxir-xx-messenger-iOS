import UIKit
import Shared
import Combine
import CloudFiles
import DI

struct BackupSetupViewModel {
    var didTapService: (CloudService, UIViewController) -> Void
}

extension BackupSetupViewModel {
    static func live() -> Self {
        class Context {
            @Dependency var service: BackupService
        }

        let context = Context()
        return .init(didTapService: context.service.authorize)
    }
}
