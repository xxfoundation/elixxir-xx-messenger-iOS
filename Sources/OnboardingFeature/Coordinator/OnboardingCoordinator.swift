import UIKit
import Shared
import Models
import Countries
import Presentation

public typealias AttributeControllerClosure = (UIViewController) -> Void

public protocol OnboardingCoordinating {
    func toChats(from: UIViewController)
    func toEmail(from: UIViewController)
    func toPhone(from: UIViewController)
    func toTerms(from: UIViewController)
    func toWelcome(from: UIViewController)
    func toUsername(from: UIViewController)
    func toRestoreList(from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
    func toSuccess(with: OnboardingSuccessModel, from: UIViewController)

    func toEmailConfirmation(
        with: AttributeConfirmation,
        from: UIViewController,
        completion: @escaping (UIViewController) -> Void
    )

    func toPhoneConfirmation(
        with: AttributeConfirmation,
        from: UIViewController,
        completion: @escaping (UIViewController) -> Void
    )

    func toCountries(
        from: UIViewController,
        _ onChoose: @escaping (Country) -> Void
    )
}

public struct OnboardingCoordinator: OnboardingCoordinating {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var replacePresenter: Presenting = ReplacePresenter()

    var emailFactory: () -> UIViewController
    var phoneFactory: () -> UIViewController
    var searchFactory: (String?) -> UIViewController
    var welcomeFactory: () -> UIViewController
    var chatListFactory: () -> UIViewController
    var termsFactory: () -> UIViewController
    var usernameFactory: () -> UIViewController
    var restoreListFactory: () -> UIViewController
    var successFactory: (OnboardingSuccessModel) -> UIViewController
    var countriesFactory: (@escaping (Country) -> Void) -> UIViewController
    var phoneConfirmationFactory: (AttributeConfirmation, @escaping AttributeControllerClosure) -> UIViewController
    var emailConfirmationFactory: (AttributeConfirmation, @escaping AttributeControllerClosure) -> UIViewController

    public init(
        emailFactory: @escaping () -> UIViewController,
        phoneFactory: @escaping () -> UIViewController,
        searchFactory: @escaping (String?) -> UIViewController,
        welcomeFactory: @escaping () -> UIViewController,
        chatListFactory: @escaping () -> UIViewController,
        termsFactory: @escaping () -> UIViewController,
        usernameFactory: @escaping () -> UIViewController,
        restoreListFactory: @escaping () -> UIViewController,
        successFactory: @escaping (OnboardingSuccessModel) -> UIViewController,
        countriesFactory: @escaping (@escaping (Country) -> Void) -> UIViewController,
        phoneConfirmationFactory: @escaping (AttributeConfirmation, @escaping AttributeControllerClosure) -> UIViewController,
        emailConfirmationFactory: @escaping (AttributeConfirmation, @escaping AttributeControllerClosure) -> UIViewController
    ) {
        self.emailFactory = emailFactory
        self.termsFactory = termsFactory
        self.phoneFactory = phoneFactory
        self.searchFactory = searchFactory
        self.welcomeFactory = welcomeFactory
        self.successFactory = successFactory
        self.usernameFactory = usernameFactory
        self.chatListFactory = chatListFactory
        self.countriesFactory = countriesFactory
        self.restoreListFactory = restoreListFactory
        self.phoneConfirmationFactory = phoneConfirmationFactory
        self.emailConfirmationFactory = emailConfirmationFactory
    }
}

public extension OnboardingCoordinator {
    func toTerms(from parent: UIViewController) {
        let screen = termsFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toEmail(from parent: UIViewController) {
        let screen = emailFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toPhone(from parent: UIViewController) {
        let screen = phoneFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toWelcome(from parent: UIViewController) {
        let screen = welcomeFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toRestoreList(from parent: UIViewController) {
        let screen = restoreListFactory()
        pushPresenter.present(screen, from: parent)
    }

    func toSuccess(with model: OnboardingSuccessModel, from parent: UIViewController) {
        let screen = successFactory(model)
        replacePresenter.present(screen, from: parent)
    }

    func toUsername(from parent: UIViewController) {
        let screen = usernameFactory()
        replacePresenter.present(screen, from: parent)
    }

    func toDrawer(_ drawer: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(drawer, from: parent)
    }

    func toChats(from parent: UIViewController) {
        let searchScreen = searchFactory(nil)
        let chatListScreen = chatListFactory()
        replacePresenter.present(chatListScreen, searchScreen, from: parent)
    }

    func toCountries(from parent: UIViewController, _ onChoose: @escaping (Country) -> Void) {
        let screen = countriesFactory(onChoose)
        pushPresenter.present(screen, from: parent)
    }

    func toEmailConfirmation(
        with confirmation: AttributeConfirmation,
        from parent: UIViewController,
        completion: @escaping (UIViewController) -> Void
    ) {
        let screen = emailConfirmationFactory(confirmation, completion)
        pushPresenter.present(screen, from: parent)
    }

    func toPhoneConfirmation(
        with confirmation: AttributeConfirmation,
        from parent: UIViewController,
        completion: @escaping (UIViewController) -> Void
    ) {
        let screen = phoneConfirmationFactory(confirmation, completion)
        pushPresenter.present(screen, from: parent)
    }
}
