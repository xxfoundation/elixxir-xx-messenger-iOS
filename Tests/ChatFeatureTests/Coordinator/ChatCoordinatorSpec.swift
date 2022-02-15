import UIKit
import Quick
import Nimble
import TestHelpers

@testable import ChatFeature

final class ChatCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: ChatCoordinator!
            var pusher: PresenterDouble!
            var bottomPresenter: PresenterDouble!

            var retryController: UIViewController!
            var contactController: UIViewController!

            beforeEach {
                pusher = PresenterDouble()
                bottomPresenter = PresenterDouble()
                retryController = UIViewController()
                contactController = UIViewController()

                sut = ChatCoordinator(
                    retryFactory: { retryController },
                    contactFactory: { _ in contactController }
                )

                sut.pusher = pusher
                sut.bottomPresenter = bottomPresenter
            }

            afterEach {
                sut = nil
                pusher = nil
                bottomPresenter = nil
                retryController = nil
                contactController = nil
            }

            context("when presenting retry sheet") {
                var parent: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    sut.toRetrySheet(from: parent)
                }

                it("should present RetrySheetController") {
                    expect(bottomPresenter.didPresentFrom).to(be(parent))
                    expect(bottomPresenter.didPresentTarget).to(be(retryController))
                }
            }

            context("when presenting members list") {
                var target: UIViewController!
                var parent: UIViewController!

                beforeEach {
                    target = UIViewController()
                    parent = UIViewController()
                    sut.toMembersList(target, from: parent)
                }

                it("should present MembersController") {
                    expect(bottomPresenter.didPresentFrom).to(be(parent))
                    expect(bottomPresenter.didPresentTarget).to(be(target))
                }
            }

            context("when presenting Popup") {
                var target: UIViewController!
                var parent: UIViewController!

                beforeEach {
                    target = UIViewController()
                    parent = UIViewController()
                    sut.toPopup(target, from: parent)
                }

                it("should present Popup") {
                    expect(bottomPresenter.didPresentFrom).to(be(parent))
                    expect(bottomPresenter.didPresentTarget).to(be(target))
                }
            }

            context("when presenting Contact") {
                var parent: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    sut.toContact(.dummy, from: parent)
                }

                it("should present ContactController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(contactController))
                }
            }

            context("when presenting menu sheet") {
                var target: UIViewController!
                var parent: UIViewController!

                beforeEach {
                    target = UIViewController()
                    parent = UIViewController()
                    sut.toMenuSheet(target, from: parent)
                }

                it("should present SheetController") {
                    expect(bottomPresenter.didPresentFrom).to(be(parent))
                    expect(bottomPresenter.didPresentTarget).to(be(target))
                }
            }
        }
    }
}
