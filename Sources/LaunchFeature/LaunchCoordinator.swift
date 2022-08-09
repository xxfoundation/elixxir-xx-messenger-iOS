import UIKit
import Models
import XXModels
import Presentation

public protocol LaunchCoordinating {
    func toChats(from: UIViewController)
    func toTerms(from: UIViewController)
    func toRequests(from: UIViewController)
    func toSearch(searching: String, from: UIViewController)
    func toOnboarding(from: UIViewController)
    func toSingleChat(with: Contact, from: UIViewController)
    func toGroupChat(with: GroupInfo, from: UIViewController)
}

public struct LaunchCoordinator: LaunchCoordinating {
    var replacePresenter: Presenting = ReplacePresenter()

    var termsFactory: (String?) -> UIViewController
    var searchFactory: (String) -> UIViewController
    var requestsFactory: () -> UIViewController
    var chatListFactory: () -> UIViewController
    var onboardingFactory: () -> UIViewController
    var singleChatFactory: (Contact) -> UIViewController
    var groupChatFactory: (GroupInfo) -> UIViewController

    public init(
        termsFactory: @escaping (String?) -> UIViewController,
        searchFactory: @escaping (String) -> UIViewController,
        requestsFactory: @escaping () -> UIViewController,
        chatListFactory: @escaping () -> UIViewController,
        onboardingFactory: @escaping () -> UIViewController,
        singleChatFactory: @escaping (Contact) -> UIViewController,
        groupChatFactory: @escaping (GroupInfo) -> UIViewController
    ) {
        self.termsFactory = termsFactory
        self.searchFactory = searchFactory
        self.requestsFactory = requestsFactory
        self.chatListFactory = chatListFactory
        self.groupChatFactory = groupChatFactory
        self.onboardingFactory = onboardingFactory
        self.singleChatFactory = singleChatFactory
    }
}

public extension LaunchCoordinator {
    func toSearch(searching: String, from parent: UIViewController) {
        let screen = searchFactory(searching)
        let chatListScreen = chatListFactory()
        replacePresenter.present(chatListScreen, screen, from: parent)
    }

    func toTerms(from parent: UIViewController) {
        let screen = termsFactory(nil)
        replacePresenter.present(screen, from: parent)
    }

    func toChats(from parent: UIViewController) {
        let screen = chatListFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toRequests(from parent: UIViewController) {
        let screen = requestsFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toOnboarding(from parent: UIViewController) {
        let screen = onboardingFactory()
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
