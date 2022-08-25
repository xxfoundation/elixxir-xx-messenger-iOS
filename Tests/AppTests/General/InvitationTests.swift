import XCTest

@testable import App

final class AppDelegateTests: XCTestCase {
    func test_invitationUniversalLink() {
        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "https://elixxir.io/connecting?username=some")!
        ))

        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "http://elixxir.io/connect?username=some")!
        ))

        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "https://io.elixxir/connect?username=some")!
        ))

        XCTAssertEqual(getUsernameFromInvitationDeepLink(
            URL(string: "https://elixxir.io/connect?username=brad")!
        ), "brad")

        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "https://elixxir.io/connect?password=value")!
        ))

        XCTAssertNil(getUsernameFromInvitationDeepLink(
            URL(string: "https://elixxir.io/connect?usernamer=some")!
        ))

        XCTAssertNotEqual(getUsernameFromInvitationDeepLink(
            URL(string: "https://elixxir.io/connect?username=anderson")!
        ), "silva")
    }
}
