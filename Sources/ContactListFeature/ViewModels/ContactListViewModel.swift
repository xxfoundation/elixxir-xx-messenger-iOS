import Models
import Combine
import XXModels
import Integration
import DependencyInjection

final class ContactListViewModel {
    @Dependency private var session: SessionType

    var contacts: AnyPublisher<[Contact], Never> {
        session.dbManager.fetchContactsPublisher(.init(authStatus: [.friend]))
            .assertNoFailure()
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
            session.dbManager.fetchContactsPublisher(contactsQuery).catch { _ in Just([]) },
            session.dbManager.fetchGroupsPublisher(groupQuery).catch { _ in Just([]) }
        )
        .map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }
}
