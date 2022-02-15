import UIKit
import Quick
import Nimble
import MenuFeature
import TestHelpers

@testable import ChatListFeature

final class ChatListCoordinatorSpec: QuickSpec {
    override func spec() {
        context("init") {
            var sut: ChatListCoordinator!
            var sider: PresenterDouble!
            var pusher: PresenterDouble!
            var bottomPresenter: PresenterDouble!

            var scanScreen: UIViewController!
            var searchScreen: UIViewController!
            var profileScreen: UIViewController!
            var settingsScreen: UIViewController!
            var contactsScreen: UIViewController!
            var requestsScreen: UIViewController!

            beforeEach {
                sider = PresenterDouble()
                pusher = PresenterDouble()
                bottomPresenter = PresenterDouble()

                scanScreen = UIViewController()
                searchScreen = UIViewController()
                profileScreen = UIViewController()
                settingsScreen = UIViewController()
                contactsScreen = UIViewController()
                requestsScreen = UIViewController()

                sut = ChatListCoordinator(
                    scanFactory: { scanScreen },
                    searchFactory: { searchScreen },
                    profileFactory: { profileScreen },
                    settingsFactory: { settingsScreen },
                    contactsFactory: { contactsScreen },
                    requestsFactory: { requestsScreen }
                )

                sut.sider = sider
                sut.pusher = pusher
                sut.bottomPresenter = bottomPresenter
            }

            afterEach {
                sut = nil
                pusher = nil
                sider = nil
                scanScreen = nil
                searchScreen = nil
                profileScreen = nil
                settingsScreen = nil
                contactsScreen = nil
                requestsScreen = nil
                bottomPresenter = nil
            }

            context("when presenting chat") {
                var target: UIViewController!
                var parent: UIViewController!

                beforeEach {
                    target = UIViewController()
                    parent = UIViewController()
                    sut.singleChatFactory = { _ in target }
                    sut.toSingleChat(with: .dummy, from: parent)
                }

                it("should present ChatController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting side menu") {
                var parent: Delegate!
                var target: UIViewController!

                beforeEach {
                    parent = Delegate()
                    target = UIViewController()
                    sut.sideMenuFactory = { _ in target }
                    sut.toSideMenu(from: parent)
                }

                it("should present side menu") {
                    expect(sider.didPresentFrom).to(be(parent))
                    expect(sider.didPresentTarget).to(be(target))
                }
            }

            context("when presenting search") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.searchFactory = { target }
                    sut.toSearch(from: parent)
                }

                it("should present SearchController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting scan") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.scanFactory = { target }
                    sut.toScan(from: parent)
                }

                it("should present ScanController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting profile") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.profileFactory = { target }
                    sut.toProfile(from: parent)
                }

                it("should present ProfileController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting contacts") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.contactsFactory = { target }
                    sut.toContacts(from: parent)
                }

                it("should present ContactListController") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }

            context("when presenting settings") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.settingsFactory = { target }
                    sut.toSettings(from: parent)
                }

                it("should present SettingsController") {
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

                it("should present GroupChatController") {
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

            context("when presenting requests") {
                var parent: UIViewController!
                var target: UIViewController!

                beforeEach {
                    parent = UIViewController()
                    target = UIViewController()
                    sut.requestsFactory = { target }
                    sut.toRequests(from: parent)
                }

                it("should present RequestsContainer") {
                    expect(pusher.didPresentFrom).to(be(parent))
                    expect(pusher.didPresentTarget).to(be(target))
                }
            }
        }
    }
}

// MARK: - Delegate

private final class Delegate: UIViewController, MenuDelegate {
    func didSelect(item: MenuItem) {}
}
