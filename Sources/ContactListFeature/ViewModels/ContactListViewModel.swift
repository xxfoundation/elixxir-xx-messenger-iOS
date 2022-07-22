import UIKit
import Models
import Combine
import XXModels
import Integration
import DependencyInjection

typealias ContactListSnapshot = NSDiffableDataSourceSnapshot<Int, Contact>

final class ContactListViewModel {
    @Dependency var session: SessionType

    var snapshotPublisher: AnyPublisher<ContactListSnapshot, Never> {
        session.dbManager.fetchContactsPublisher(.init(authStatus: [.friend]))
            .assertNoFailure()
            .map {
                let removingMyself = $0.filter { $0.id != self.session.myId }
                var snapshot = ContactListSnapshot()
                snapshot.appendSections([0])
                snapshot.appendItems(removingMyself, toSection: 0)
                return snapshot
            }
            .eraseToAnyPublisher()
    }

    var requestCount: AnyPublisher<Int, Never> {
        let groupQuery = Group.Query(authStatus: [.pending])
        let contactsQuery = Contact.Query(authStatus: [
            .verified,
            .confirming,
            .confirmationFailed,
            .verificationFailed,
            .verificationInProgress
        ])

        return Publishers.CombineLatest(
            session.dbManager.fetchContactsPublisher(contactsQuery).assertNoFailure(),
            session.dbManager.fetchGroupsPublisher(groupQuery).assertNoFailure()
        )
        .map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }
}
