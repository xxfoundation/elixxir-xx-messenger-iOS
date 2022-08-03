import XCTest

@testable import App

final class AppDelegateTests: XCTestCase {
    func test_invitationUniversalLink() {
        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "https://xx.network/messenger/invite?username=some")!
        ))

        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "http://xx.network/messenger/invitation?username=some")!
        ))

        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "https://network.xx/messenger/invitation?username=some")!
        ))

        XCTAssertEqual(getUsernameFromInvitationDeepLink(
            URL(string: "https://xx.network/messenger/invitation?username=brad")!
        ), "brad")

        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "https://xx.network/messenger/invitation?password=value")!
        ))

        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "https://xx.network/xxmessenger/invitation?username=some")!
        ))

        XCTAssertNotEqual(getUsernameFromInvitationDeepLink(
            URL(string: "https://xx.network/messenger/invitation?username=anderson")!
        ), "silva")
    }
}
