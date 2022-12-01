import UIKit
import Shared
import Combine
import CloudFiles
import ComposableArchitecture

struct BackupSetupViewModel {
  var didTapService: (CloudService, UIViewController) -> Void
}

extension BackupSetupViewModel {
  static func live() -> Self {
    class Context {
      @Dependency(\.backupService) var service
    }

    let context = Context()
    return .init(didTapService: context.service.authorize)
  }
}
