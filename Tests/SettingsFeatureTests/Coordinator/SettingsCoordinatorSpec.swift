import UIKit
import Quick
import Nimble
import TestHelpers

@testable import SettingsFeature

final class SettingsCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: SettingsCoordinator!
            var pusher: PresenterDouble!
            var presenter: PresenterDouble!
            var bottomPresenter: PresenterDouble!

            beforeEach {
                pusher = PresenterDouble()
                presenter = PresenterDouble()
                bottomPresenter = PresenterDouble()

                sut = SettingsCoordinator()

                sut.pusher = pusher
                sut.presenter = presenter
                sut.bottomPresenter = bottomPresenter
            }

            context("when presenting advanced settings") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.advancedFactory = { target }
                    sut.toAdvanced(from: parent)
                }

                it("should present AdvancedScreen") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting Popup") {
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

            context("when presenting ActivityViewController") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.activityControllerFactory = { _ in target }
                    sut.toActivityController(with: [0], from: parent)
                }

                it("should present ActivityViewController") {
                    expect(presenter.didPresentFrom).to(be(parent))
                    expect(presenter.didPresentTarget).to(be(target))
                }
            }
        }
    }
}
