import XCTest

@testable import App

final class AppDelegateTests: XCTestCase {
    func test_invitationDeeplink() {
        let host = "messenger"
        let query = "invitation"
        let scheme = "xxnetwork"
        let username = "john_doe"

        let url = URL(string: "\(scheme)://\(host)?\(query)=\(username)")!
        XCTAssertEqual(getUsernameFromInvitationDeepLink(url), username)

        let malformedURL = URL(string: "\(scheme)\(host)\(query)\(username)")!
        XCTAssertNil(getUsernameFromInvitationDeepLink(malformedURL))

        let urlAnotherUsername = URL(string: "\(scheme)://\(host)?\(query)=asdfg")!
        XCTAssertNotEqual(getUsernameFromInvitationDeepLink(urlAnotherUsername), username)
    }
}
