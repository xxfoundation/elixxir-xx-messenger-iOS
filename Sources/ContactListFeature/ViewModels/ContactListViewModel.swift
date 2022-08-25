import Models
import Combine
import XXModels
import Defaults
import Integration
import ReportingFeature
import DependencyInjection

final class ContactListViewModel {
    @Dependency private var session: SessionType
    @Dependency private var reportingStatus: ReportingStatus

    var contacts: AnyPublisher<[Contact], Never> {
        let query = Contact.Query(
            authStatus: [.friend],
            isBlocked: reportingStatus.isEnabled() ? false : nil,
            isBanned: reportingStatus.isEnabled() ? false: nil
        )

        return session.dbManager.fetchContactsPublisher(query)
            .assertNoFailure()
            .map { $0.filter { $0.id != self.session.myId }}
            .eraseToAnyPublisher()
    }

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
}
