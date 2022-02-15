import UIKit
import Quick
import Nimble
import TestHelpers

@testable import ProfileFeature

final class ProfileCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: ProfileCoordinator!
            var pusher: PresenterDouble!
            var presenter: PresenterDouble!
            var bottomPresenter: PresenterDouble!

            beforeEach {
                sut = ProfileCoordinator()
                pusher = PresenterDouble()
                presenter = PresenterDouble()
                bottomPresenter = PresenterDouble()

                sut.pusher = pusher
                sut.presenter = presenter
                sut.bottomPresenter = bottomPresenter
            }

            afterEach {
                sut = nil
                pusher = nil
                presenter = nil
                bottomPresenter = nil
            }

            context("when presenting image picker") {
                var parent: UIViewController!
                var target: UIImagePickerController!

                beforeEach {
                    parent = UIViewController()
                    target = UIImagePickerController()
                    sut.imagePickerFactory = { target }
                    sut.toPhotos(from: parent)
                }

                it("should present UIImagePickerController") {
                    expect(presenter.didPresentFrom).to(be(parent))
                    expect(presenter.didPresentTarget).to(be(target))
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

                it("should present ProfileEmailController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
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

                it("should present ProfilePhoneController") {
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

            context("when presenting code") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.codeFactory = { _,_ in target }

                    sut.toCode(
                        with: .init(content: ""),
                        from: parent
                    ) { _,_ in }
                }

                it("should present CodeController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }
        }
    }
}
