import Combine
import XXModels
import XXClient
import Defaults
import Foundation
import ReportingFeature
import DependencyInjection

final class MenuViewModel {
    @Dependency var database: Database
    @Dependency var reportingStatus: ReportingStatus

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
          database.fetchContactsPublisher(contactsQuery)
            .replaceError(with: []),
          database.fetchGroupsPublisher(groupQuery)
            .replaceError(with: [])
        )
        .map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }

    var xxdk: String {
        GetVersion.live()
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
