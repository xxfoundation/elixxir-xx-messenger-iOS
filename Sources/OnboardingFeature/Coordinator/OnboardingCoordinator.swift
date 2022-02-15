import UIKit
import Shared
import Models
import Countries
import Presentation

public protocol OnboardingCoordinating {
    func toChats(from: UIViewController)
    func toEmail(from: UIViewController)
    func toPhone(from: UIViewController)
    func toWelcome(from: UIViewController)
    func toStart(with: String, from: UIViewController)
    func toUsername(with: String, from: UIViewController)
    func toSuccess(isEmail: Bool, from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)

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
    public init(chatListFactory: @escaping () -> UIViewController) {
        self.chatListFactory = chatListFactory
    }

    var pusher: Presenting = PushPresenter()
    var replacer: Presenting = ReplacePresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    // MARK: Factories

    var chatListFactory: () -> UIViewController

    var welcomeFactory: () -> UIViewController
        = OnboardingWelcomeController.init

    var emailFactory: () -> UIViewController
        = OnboardingEmailController.init

    var phoneFactory: () -> UIViewController
        = OnboardingPhoneController.init

    var startFactory: (String) -> UIViewController
        = OnboardingStartController.init(_:)

    var usernameFactory: (String) -> UIViewController
        = OnboardingUsernameController.init(_:)

    var successFactory: (Bool) -> UIViewController
        = OnboardingSuccessController.init(_:)

    var countriesFactory: (@escaping (Country) -> Void) -> UIViewController
        = CountryListController.init(_:)

    var phoneConfirmationFactory: (AttributeConfirmation, @escaping (UIViewController) -> Void) -> UIViewController
        = OnboardingPhoneConfirmationController.init(_:_:)

    var emailConfirmationFactory: (AttributeConfirmation, @escaping (UIViewController) -> Void) -> UIViewController
        = OnboardingEmailConfirmationController.init(_:_:)
}

public extension OnboardingCoordinator {
    func toSuccess(
        isEmail: Bool,
        from parent: UIViewController
    ) {
        let screen = successFactory(isEmail)
        replacer.present(screen, from: parent)
    }

    func toEmailConfirmation(
        with confirmation: AttributeConfirmation,
        from parent: UIViewController,
        completion: @escaping (UIViewController) -> Void
    ) {
        let screen = emailConfirmationFactory(confirmation, completion)
        pusher.present(screen, from: parent)
    }

    func toPhoneConfirmation(
        with confirmation: AttributeConfirmation,
        from parent: UIViewController,
        completion: @escaping (UIViewController) -> Void
    ) {
        let screen = phoneConfirmationFactory(confirmation, completion)
        pusher.present(screen, from: parent)
    }

    func toEmail(from parent: UIViewController) {
        let screen = emailFactory()
        replacer.present(screen, from: parent)
    }

    func toPhone(from parent: UIViewController) {
        let screen = phoneFactory()
        replacer.present(screen, from: parent)
    }

    func toCountries(
        from parent: UIViewController,
        _ onChoose: @escaping (Country) -> Void
    ) {
        let screen = countriesFactory(onChoose)
        pusher.present(screen, from: parent)
    }

    func toUsername(with ndf: String, from parent: UIViewController) {
        let screen = usernameFactory(ndf)
        replacer.present(screen, from: parent)
    }

    func toChats(from parent: UIViewController) {
        let screen = chatListFactory()
        replacer.present(screen, from: parent)
    }

    func toStart(
        with ndf: String,
        from parent: UIViewController
    ) {
        let screen = startFactory(ndf)
        replacer.present(screen, from: parent)
    }

    func toPopup(
        _ popup: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(popup, from: parent)
    }

    func toWelcome(from parent: UIViewController) {
        let screen = welcomeFactory()
        replacer.present(screen, from: parent)
    }
}
