import UIKit
import Quick
import Nimble
import Integration
import TestHelpers

@testable import SearchFeature

final class SearchCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: SearchCoordinator!
            var pusher: PresenterDouble!
            var bottomPresenter: PresenterDouble!

            beforeEach {
                sut = SearchCoordinator()
                pusher = PresenterDouble()
                bottomPresenter = PresenterDouble()
                sut.pusher = pusher
                sut.bottomPresenter = bottomPresenter
            }

            afterEach {
                sut = nil
                pusher = nil
                bottomPresenter = nil
            }

            context("when presenting add screen") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.contactFactory = { _ in target }
                    sut.toContact(.dummy, from: parent)
                }

                it("should present AddScreen") {
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
        }
    }
}
