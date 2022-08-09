import Models
import Combine
import XXModels
import Defaults
import ReportingFeature
import DependencyInjection

import Foundation
import XXClient

final class ContactListViewModel {
    @Dependency var database: Database
    @Dependency var userDiscovery: UserDiscovery
    @Dependency private var reportingStatus: ReportingStatus

    var myId: Data {
        try! GetIdFromContact.live(userDiscovery.getContact())
    }

    var contacts: AnyPublisher<[Contact], Never> {
        let query = Contact.Query(
            authStatus: [.friend],
            isBlocked: reportingStatus.isEnabled() ? false : nil,
            isBanned: reportingStatus.isEnabled() ? false: nil
        )

        return database.fetchContactsPublisher(query)
            .assertNoFailure()
            .map { $0.filter { $0.id != self.myId }}
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
            database.fetchContactsPublisher(contactsQuery).assertNoFailure(),
            database.fetchGroupsPublisher(groupQuery).assertNoFailure()
        )
        .map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }
}
