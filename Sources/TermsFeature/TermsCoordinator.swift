import UIKit
import Presentation

public struct TermsCoordinator {
    var presentChatList: (UIViewController) -> Void
    var presentUsername: (String, UIViewController) -> Void
}

public extension TermsCoordinator {
    static func live(
        usernameFactory: @escaping (String) -> UIViewController,
        chatListFactory: @escaping () -> UIViewController
    ) -> Self {
        .init(
            presentChatList: { parent in
                let presenter = ReplacePresenter()
                presenter.present(chatListFactory(), from: parent)
            },
            presentUsername: { ndf, parent in
                let presenter = PushPresenter()
                presenter.present(usernameFactory(ndf), from: parent)
            }
        )
    }
}
