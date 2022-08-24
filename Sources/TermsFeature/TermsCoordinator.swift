import UIKit
import Presentation

public struct TermsCoordinator {
    var presentChatList: (UIViewController) -> Void
    var presentUsername: (UIViewController) -> Void
}

public extension TermsCoordinator {
    static func live(
        usernameFactory: @escaping () -> UIViewController,
        chatListFactory: @escaping () -> UIViewController
    ) -> Self {
        .init(
            presentChatList: { parent in
                let presenter = ReplacePresenter()
                presenter.present(chatListFactory(), from: parent)
            },
            presentUsername: { parent in
                let presenter = PushPresenter()
                presenter.present(usernameFactory(), from: parent)
            }
        )
    }
}
