import Combine
import XXModels
import Defaults
import Foundation
import Integration
import ReportingFeature
import DependencyInjection

final class MenuViewModel {
    @Dependency private var session: SessionType
    @Dependency private var reportingStatus: ReportingStatus

    @KeyObject(.avatar, defaultValue: nil) var avatar: Data?
    @KeyObject(.username, defaultValue: "") var username: String

    var requestCount: AnyPublisher<Int, Never> {
        let groupQuery = Group.Query(
            authStatus: [.pending],
            isLeaderBlocked: reportingStatus.isEnabled() ? false : nil,
            isLeaderBanned: reportingStatus.isEnabled() ? false : nil
        )

        let contactsQuery = Contact.Query(
            authStatus: [
                .verified,
                .confirming,
                .confirmationFailed,
                .verificationFailed,
                .verificationInProgress
            ],
            isBlocked: reportingStatus.isEnabled() ? false : nil,
            isBanned: reportingStatus.isEnabled() ? false : nil
        )

        return Publishers.CombineLatest(
            session.dbManager.fetchContactsPublisher(contactsQuery).assertNoFailure(),
            session.dbManager.fetchGroupsPublisher(groupQuery).assertNoFailure()
        )
        .map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }

    var xxdk: String {
        session.version
    }

    var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var referralDeeplink: String {
        "https://elixxir.io/connect?username=\(username)"
    }
}
