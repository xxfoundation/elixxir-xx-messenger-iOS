import DI
import UIKit
import XXModels
import PushFeature
import ChatFeature
import SearchFeature
import LaunchFeature
import ChatListFeature
import RequestsFeature
import XXMessengerClient

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
          if let messenger = try? DI.Container.shared.resolve() as Messenger,
             let _ = try? messenger.ud.get()?.getContact() {
            if !(navigationController.viewControllers.last is SearchContainerController) {
              navigationController.setViewControllers([
                ChatListController(),
                SearchContainerController(username)
              ], animated: true)
            } else {
              (navigationController.viewControllers.last as? SearchContainerController)?.startSearchingFor(username)
            }
          }
        case .contactChat(id: let id):
          if let database: Database = try? DI.Container.shared.resolve(),
             let contact = try? database.fetchContacts(.init(id: [id])).first {
            navigationController.setViewControllers([
              ChatListController(),
              SingleChatController(contact)
            ], animated: true)
          }
        case .groupChat(id: let id):
          if let database: Database = try? DI.Container.shared.resolve(),
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
