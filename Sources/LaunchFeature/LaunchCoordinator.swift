import UIKit
import Models
import XXModels
import Presentation

public protocol LaunchCoordinating {
    func toChats(from: UIViewController)
    func toSearch(from: UIViewController)
    func toRequests(from: UIViewController)
    func toOnboarding(with: String, from: UIViewController)
    func toSingleChat(with: Contact, from: UIViewController)
    func toGroupChat(with: GroupInfo, from: UIViewController)
}

public struct LaunchCoordinator: LaunchCoordinating {
    var replacePresenter: Presenting = ReplacePresenter()

    var searchFactory: () -> UIViewController
    var requestsFactory: () -> UIViewController
    var chatListFactory: () -> UIViewController
    var onboardingFactory: (String) -> UIViewController
    var singleChatFactory: (Contact) -> UIViewController
    var groupChatFactory: (GroupInfo) -> UIViewController

    public init(
        searchFactory: @escaping () -> UIViewController,
        requestsFactory: @escaping () -> UIViewController,
        chatListFactory: @escaping () -> UIViewController,
        onboardingFactory: @escaping (String) -> UIViewController,
        singleChatFactory: @escaping (Contact) -> UIViewController,
        groupChatFactory: @escaping (GroupInfo) -> UIViewController
    ) {
        self.searchFactory = searchFactory
        self.requestsFactory = requestsFactory
        self.chatListFactory = chatListFactory
        self.groupChatFactory = groupChatFactory
        self.onboardingFactory = onboardingFactory
        self.singleChatFactory = singleChatFactory
    }
}

public extension LaunchCoordinator {
    func toSearch(from parent: UIViewController) {
        let screen = searchFactory()
        let chatListScreen = chatListFactory()
        replacePresenter.present(chatListScreen, screen, from: parent)
    }

    func toChats(from parent: UIViewController) {
        let screen = chatListFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toOnboarding(with ndf: String, from parent: UIViewController) {
        let screen = onboardingFactory(ndf)
        replacePresenter.present(screen, from: parent)
    }

    func toSingleChat(with contact: Contact, from parent: UIViewController) {
        let chatListScreen = chatListFactory()
        let singleChatScreen = singleChatFactory(contact)
        replacePresenter.present(chatListScreen, singleChatScreen, from: parent)
    }

    func toGroupChat(with group: GroupInfo, from parent: UIViewController) {
        let chatListScreen = chatListFactory()
        let groupChatScreen = groupChatFactory(group)
        replacePresenter.present(chatListScreen, groupChatScreen, from: parent)
    }
}
