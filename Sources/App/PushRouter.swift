import UIKit
import PushFeature
import ChatFeature
import SearchFeature
import LaunchFeature
import ChatListFeature
import RequestsFeature
import DependencyInjection
import XXModels

extension PushRouter {
    static func live(navigationController: UINavigationController) -> PushRouter {
        PushRouter { route, completion in
            if let launchController = navigationController.viewControllers.last as? LaunchController {
                launchController.pendingPushRoute = route
            } else {
                switch route {
                case .requests:
                    if !(navigationController.viewControllers.last is RequestsContainerController) {
                        navigationController.setViewControllers([RequestsContainerController()], animated: true)
                    }
                case .search(username: let username):
                    if !(navigationController.viewControllers.last is SearchContainerController) {
                        navigationController.setViewControllers([
                            ChatListController(),
                            SearchContainerController(username)
                        ], animated: true)
                    }
                case .contactChat(id: let id):
                    if let database: Database = try? DependencyInjection.Container.shared.resolve(),
                       let contact = try? database.fetchContacts(.init(id: [id])).first {
                        navigationController.setViewControllers([
                            ChatListController(),
                            SingleChatController(contact)
                        ], animated: true)
                    }
                case .groupChat(id: let id):
                    if let database: Database = try? DependencyInjection.Container.shared.resolve(),
                       let info = try? database.fetchGroupInfos(.init(groupId: id)).first {
                        navigationController.setViewControllers([
                            ChatListController(),
                            GroupChatController(info)
                        ], animated: true)
                    }
                }
            }

            completion()
        }
    }
}
