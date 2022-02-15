import UIKit
import Quick
import Theme
import Nimble
import Combine
import TestHelpers
import DependencyInjection

@testable import OnboardingFeature

final class OnboardingCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: OnboardingCoordinator!
            var pusher: PresenterDouble!
            var replacer: PresenterDouble!
            var bottomPresenter: PresenterDouble!
            var chatsController: UIViewController!

            beforeEach {
                pusher = PresenterDouble()
                replacer = PresenterDouble()
                bottomPresenter = PresenterDouble()

                chatsController = UIViewController()

                DependencyInjection.Container.shared
                    .register(StatusBarControllerDouble() as StatusBarStyleControlling)

                sut = OnboardingCoordinator(chatListFactory: { chatsController })

                sut.pusher = pusher
                sut.replacer = replacer
                sut.bottomPresenter = bottomPresenter
            }

            afterEach {
                sut = nil
                pusher = nil
                replacer = nil
                bottomPresenter = nil
                chatsController = nil
            }

            context("when presenting success") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.successFactory = { _ in target }
                    sut.toSuccess(isEmail: false, from: parent)
                }

                it("should present OnboardingSuccessController") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(target))
                }
            }

            context("when presenting username") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.usernameFactory = { _ in target }
                    sut.toUsername(with: "", from: parent)
                }

                it("should present OnboardingUsernameController") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(target))
                }
            }

            context("when presenting chats") {
                var parent: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    sut.toChats(from: parent)
                }

                it("should present ChatsController") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(chatsController))
                }
            }

            context("when presenting email") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.emailFactory = { target }
                    sut.toEmail(from: parent)
                }

                it("should present OnboardingEmailController") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(target))
                }
            }

            context("when presenting phone") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.phoneFactory = { target }
                    sut.toPhone(from: parent)
                }

                it("should present OnboardingPhoneController") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(target))
                }
            }

            context("when presenting countries") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.countriesFactory = { _ in target }
                    sut.toCountries(from: parent, { _ in })
                }

                it("should present CountriesController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting popup") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.toPopup(target, from: parent)
                }

                it("should present Popup") {
                    expect(bottomPresenter.didPresentFrom).to(be(parent))
                    expect(bottomPresenter.didPresentTarget).to(be(target))
                }
            }

            context("when presenting welcome") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.welcomeFactory = { target }
                    sut.toWelcome(from: parent)
                }

                it("should present OnboardingWelcomeScreen") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(target))
                }
            }

            context("when presenting start") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.startFactory = { _ in target }
                    sut.toStart(with: "ndf", from: parent)
                }

                it("should present OnboardingStartScreen") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(target))
                }
            }

            context("when presenting email confirmation") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.emailConfirmationFactory = { _,_ in target }
                    sut.toEmailConfirmation(with: .init(content: ""), from: parent, completion: { _ in })
                }

                it("should present OnboardingEmailConfirmationScreen") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting phone confirmation") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.phoneConfirmationFactory = { _,_ in target }
                    sut.toPhoneConfirmation(with: .init(content: ""), from: parent, completion: { _ in })
                }

                it("should present OnboardingPhoneConfirmationScreen") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }
        }
    }
}

// MARK: - StatusBarControllerDouble

private final class StatusBarControllerDouble: StatusBarStyleControlling {
    var didSetStyle: UIStatusBarStyle?

    let style = CurrentValueSubject<UIStatusBarStyle, Never>(.lightContent)
    var cancellables = Set<AnyCancellable>()

    init() {
        style
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in didSetStyle = $0 }
            .store(in: &cancellables)
    }
}
