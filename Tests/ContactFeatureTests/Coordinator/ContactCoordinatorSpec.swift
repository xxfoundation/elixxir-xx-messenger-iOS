import UIKit
import Quick
import Nimble
import ChatFeature
import TestHelpers

@testable import ContactFeature

final class ContactCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: ContactCoordinator!
            var pusher: PresenterDouble!
            var replacer: PresenterDouble!
            var presenter: PresenterDouble!
            var bottomPresenter: PresenterDouble!

            var requestsScreen: UIViewController!

            beforeEach {
                pusher = PresenterDouble()
                replacer = PresenterDouble()
                presenter = PresenterDouble()
                requestsScreen = UIViewController()
                bottomPresenter = PresenterDouble()

                sut = ContactCoordinator(requestsFactory: { requestsScreen })

                sut.pusher = pusher
                sut.replacer = replacer
                sut.presenter = presenter
                sut.bottomPresenter = bottomPresenter
            }

            afterEach {
                sut = nil
                pusher = nil
                replacer = nil
                presenter = nil
                requestsScreen = nil
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

            context("when presenting single chat") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.singleChatFactory = { _ in target }
                    sut.toSingleChat(with: .dummy, from: parent)
                }

                it("should present ChatController") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(target))
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

                it("should present NickameController") {
                    expect(bottomPresenter.didPresentFrom).to(be(parent))
                    expect(bottomPresenter.didPresentTarget).to(be(target))
                }
            }

            context("when presenting requests") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.requestsFactory = { target }
                    sut.toRequests(from: parent)
                }

                it("should present RequestsController") {
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
        }
    }
}
