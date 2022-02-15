import UIKit
import Quick
import Nimble
import TestHelpers

@testable import ContactListFeature

final class ContactListCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: ContactListCoordinator!
            var pusher: PresenterDouble!
            var replacer: PresenterDouble!
            var bottomPresenter: PresenterDouble!
            var fullscreenPresenter: PresenterDouble!

            var scanScreen: UIViewController!
            var groupScreen: UIViewController!
            var searchScreen: UIViewController!
            var requestsScreen: UIViewController!

            beforeEach {
                scanScreen = UIViewController()
                searchScreen = UIViewController()

                sut = ContactListCoordinator(
                    scanFactory: { scanScreen },
                    searchFactory: { searchScreen },
                    newGroupFactory: { groupScreen },
                    requestsFactory: { requestsScreen }
                )

                pusher = PresenterDouble()
                replacer = PresenterDouble()
                bottomPresenter = PresenterDouble()
                fullscreenPresenter = PresenterDouble()

                sut.pusher = pusher
                sut.replacer = replacer
                sut.bottomPresenter = bottomPresenter
                sut.fullscreenPresenter = fullscreenPresenter
            }

            afterEach {
                sut = nil
                pusher = nil
                replacer = nil
                scanScreen = nil
                groupScreen = nil
                searchScreen = nil
                requestsScreen = nil
                bottomPresenter = nil
                fullscreenPresenter = nil
            }

            context("when presenting contact details") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.contactFactory = { _ in target }
                    sut.toContact(.dummy, from: parent)
                }

                it("should present contact details screen") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting SearchScreen") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.searchFactory = { target }
                    sut.toSearch(from: parent)
                }

                it("should present SearchScreen") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting scan screen") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.scanFactory = { target }
                    sut.toScan(from: parent)
                }

                it("should present qr screen") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting new group") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.newGroupFactory = { target }
                    sut.toNewGroup(from: parent)
                }

                it("should present new group") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting group chat") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.groupChatFactory = { _ in target }
                    sut.toGroupChat(with: .init(
                        group: .dummy,
                        members: [],
                        lastMessage: nil
                    ), from: parent)
                }

                it("should present group chat") {
                    expect(replacer.didPresentFrom).to(be(parent))
                    expect(replacer.didPresentTarget).to(be(target))
                }
            }

            context("when presenting group popup") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.groupPopupFactory = { _,_ in target }
                    sut.toGroupPopup(with: 0, from: parent, { _,_  in })
                }

                it("should present group popup") {
                    expect(fullscreenPresenter.didPresentFrom).to(be(parent))
                }
            }
        }
    }
}
