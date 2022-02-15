import UIKit
import Quick
import Nimble
import TestHelpers

@testable import ScanFeature

final class ScanCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: ScanCoordinator!
            var pusher: PresenterDouble!
            var replacer: PresenterDouble!

            var contactsController: UIViewController!
            var requestsController: UIViewController!

            beforeEach {
                pusher = PresenterDouble()
                replacer = PresenterDouble()
                contactsController = UIViewController()
                requestsController = UIViewController()

                sut = ScanCoordinator(
                    contactsFactory: { contactsController },
                    requestsFactory: { requestsController }
                )

                sut.pusher = pusher
                sut.replacer = replacer
            }

            afterEach {
                sut = nil
                pusher = nil
                replacer = nil
                contactsController = nil
                requestsController = nil
            }

            context("when presenting add") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.contactFactory = { _ in target }
                    sut.toContact(.dummy, from: parent)
                }

                it("should present ContactController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting contacts") {
                var parent: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    sut.toContacts(from: parent)
                }

                it("should present ContactListController") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(contactsController))
                }
            }

            context("when presenting requests") {
                var parent: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    sut.toRequests(from: parent)
                }

                it("should present RequestsController") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(requestsController))
                }
            }
        }
    }
}
