import UIKit
import Dependencies
import AppNavigation

import ChatFeature
import LaunchFeature
import SearchFeature
import ChatListFeature
import RequestsFeature

extension PushNotificationRouter {
  public static func live(navigationController: UINavigationController) -> PushNotificationRouter {
    PushNotificationRouter { route, completion in
      @Dependency(\.navigator) var navigator
      @Dependency(\.app.dbManager) var dbManager

      if let launchController = navigationController.viewControllers.last as? LaunchController {
        launchController.pendingPushNotificationRoute = route
      } else {
        switch route {
        case .requests:
          if !(navigationController.viewControllers.last is RequestsContainerController) {
            navigator.perform(PresentRequests(on: navigationController))
          }

        case .search(username: let username):
          if !(navigationController.viewControllers.last is SearchContainerController) {
            navigator.perform(PresentSearch(
              searching: username,
              fromOnboarding: true,
              on: navigationController,
              animated: true
            ))
          } else {
            (navigationController.viewControllers.last as? SearchContainerController)?
              .startSearchingFor(username)
          }

        case .contactChat(id: let id):
          if let contact = try? dbManager.getDB().fetchContacts(.init(id: [id])).first {
            navigator.perform(SetStack([
              ChatListController(), SingleChatController(contact)
            ], on: navigationController))
          }

        case .groupChat(id: let id):
          if let groupInfo = try? dbManager.getDB().fetchGroupInfos(.init(groupId: id)).first {
            navigator.perform(SetStack([
              ChatListController(), GroupChatController(groupInfo)
            ], on: navigationController))
          }
        }
      }
      completion()
    }
  }
}
