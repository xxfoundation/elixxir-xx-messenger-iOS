import XCTest

@testable import App

final class AppDelegateTests: XCTestCase {
    func test_invitationDeeplink() {
        XCTAssertNil(
            getUsernameFromInvitationDeepLink(URL(string: "http://messenger?invitation=john_doe")!)
        )

        XCTAssertNotEqual(
            getUsernameFromInvitationDeepLink(URL(string: "xxnetwork://messenger?invitation=the_rock")!),
            "john_doe"
        )

        XCTAssertEqual(
            getUsernameFromInvitationDeepLink(URL(string: "xxnetwork://messenger?invitation=john_doe")!),
            "john_doe"
        )
    }
}
