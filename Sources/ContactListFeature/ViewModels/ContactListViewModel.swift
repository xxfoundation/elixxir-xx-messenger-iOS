import Models
import Combine
import XXModels
import Defaults
import Integration
import DependencyInjection

final class ContactListViewModel {
    @Dependency private var session: SessionType

    @KeyObject(.isReportingEnabled, defaultValue: true) var isReportingEnabled: Bool

    var contacts: AnyPublisher<[Contact], Never> {
        let query = Contact.Query(
            authStatus: [.friend],
            isBlocked: isReportingEnabled ? false : nil,
            isBanned: isReportingEnabled ? false: nil
        )

        return session.dbManager.fetchContactsPublisher(query)
            .assertNoFailure()
            .map { $0.filter { $0.id != self.session.myId }}
            .eraseToAnyPublisher()
    }

    var requestCount: AnyPublisher<Int, Never> {
        let groupQuery = Group.Query(
            authStatus: [.pending],
            isLeaderBlocked: isReportingEnabled ? false : nil,
            isLeaderBanned: isReportingEnabled ? false : nil
        )

        let contactsQuery = Contact.Query(
            authStatus: [
                .verified,
                .confirming,
                .confirmationFailed,
                .verificationFailed,
                .verificationInProgress
            ],
            isBlocked: isReportingEnabled ? false : nil,
            isBanned: isReportingEnabled ? false : nil
        )

        return Publishers.CombineLatest(
            session.dbManager.fetchContactsPublisher(contactsQuery).assertNoFailure(),
            session.dbManager.fetchGroupsPublisher(groupQuery).assertNoFailure()
        )
        .map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }
}
