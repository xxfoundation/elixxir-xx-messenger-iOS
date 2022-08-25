import UIKit
import PushFeature
import Integration
import ChatFeature
import SearchFeature
import LaunchFeature
import ChatListFeature
import RequestsFeature
import DependencyInjection

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
                    if let _ = try? DependencyInjection.Container.shared.resolve() as SessionType,
                       !(navigationController.viewControllers.last is SearchContainerController) {
                        navigationController.setViewControllers([
                            ChatListController(),
                            SearchContainerController(username)
                        ], animated: true)
                    }
                case .contactChat(id: let id):
                    if let session = try? DependencyInjection.Container.shared.resolve() as SessionType,
                       let contact = try? session.dbManager.fetchContacts(.init(id: [id])).first {
                        navigationController.setViewControllers([
                            ChatListController(),
                            SingleChatController(contact)
                        ], animated: true)
                    }
                case .groupChat(id: let id):
                    if let session = try? DependencyInjection.Container.shared.resolve() as SessionType,
                       let info = try? session.dbManager.fetchGroupInfos(.init(groupId: id)).first {
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
