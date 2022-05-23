import Models
import Combine
import Integration
import DependencyInjection

final class ContactListViewModel {
    @Dependency private var session: SessionType

    var contacts: AnyPublisher<[Contact], Never> {
        session.contacts(.friends).eraseToAnyPublisher()
    }

    var requestCount: AnyPublisher<Int, Never> {
        Publishers.CombineLatest(
            session.contacts(.received),
            session.groups(.pending)
        ).map { (contacts, groups) in
            let contactRequests = contacts.filter {
                $0.status == .verified ||
                $0.status == .confirming ||
                $0.status == .confirmationFailed ||
                $0.status == .verificationFailed ||
                $0.status == .verificationInProgress
            }

            let groupRequests = groups.filter {
                $0.status == .pending
            }

            return contactRequests.count + groupRequests.count
        }.eraseToAnyPublisher()
    }
}
