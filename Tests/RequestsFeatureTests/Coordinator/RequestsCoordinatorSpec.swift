import Quick
import UIKit
import Nimble
import TestHelpers

@testable import RequestsFeature

final class RequestsCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: RequestsCoordinator!
            var pusher: PresenterDouble!
            var bottomPresenter: PresenterDouble!
            var searchController: UIViewController!

            beforeEach {
                pusher = PresenterDouble()
                bottomPresenter = PresenterDouble()
                searchController = UIViewController()

                sut = RequestsCoordinator(searchFactory: { searchController })

                sut.pusher = pusher
                sut.bottomPresenter = bottomPresenter
            }

            afterEach {
                sut = nil
                pusher = nil
                bottomPresenter = nil
                searchController = nil
            }

            context("when presenting search") {
                var parent: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    sut.toSearch(from: parent)
                }

                it("should present SearchController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(searchController))
                }
            }

            context("when presenting contact") {
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

            context("when presenting VerifyingFactory") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.verifyingFactory = { target }
                    sut.toVerifying(from: parent)
                }

                it("should present VerifyingScreen") {
                    expect(bottomPresenter.didPresentFrom).to(be(parent))
                    expect(bottomPresenter.didPresentTarget).to(be(target))
                }
            }

            context("when presenting nickname") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.nicknameFactory = { _,_ in target }
                    sut.toNickname(from: parent, prefilled: "", { _ in })
                }

                it("should present NicknameController") {
                    expect(bottomPresenter.didPresentFrom).to(be(parent))
                    expect(bottomPresenter.didPresentTarget).to(be(target))
                }
            }
        }
    }
}
