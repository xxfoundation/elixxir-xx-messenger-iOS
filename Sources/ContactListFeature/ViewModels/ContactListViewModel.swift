import Models
import Combine
import XXModels
import Integration
import DependencyInjection

final class ContactListViewModel {
    @Dependency private var session: SessionType

    var contacts: AnyPublisher<[Contact], Never> {
        let query = Contact.Query(authStatus: [.friend], isBlocked: false, isBanned: false)

        return session.dbManager.fetchContactsPublisher(query)
            .assertNoFailure()
            .map { $0.filter { $0.id != self.session.myId }}
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
        ], isBlocked: false, isBanned: false)

        return Publishers.CombineLatest(
            session.dbManager.fetchContactsPublisher(contactsQuery).assertNoFailure(),
            session.dbManager.fetchGroupsPublisher(groupQuery).assertNoFailure()
        )
        .map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }
}
