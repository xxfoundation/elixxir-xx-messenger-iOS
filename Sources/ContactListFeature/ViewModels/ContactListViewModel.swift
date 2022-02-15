import Models
import Combine
import Integration
import DependencyInjection

final class ContactListViewModel {
    @Dependency private var session: SessionType

    var contacts: AnyPublisher<[Contact], Never> {
        contactsRelay.eraseToAnyPublisher()
    }

    var requestCount: AnyPublisher<Int, Never> {
        Publishers.CombineLatest(
            session.contacts(.received),
            session.groups(.pending)
        ).map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let contactsRelay = CurrentValueSubject<[Contact], Never>([])
    private let searchQueryRelay = CurrentValueSubject<String, Never>("")

    init() {
        Publishers.CombineLatest(
            session.contacts(.friends),
            searchQueryRelay
        )
            .map { contacts, query -> [Contact] in
                guard !query.isEmpty else { return contacts }

                return contacts.filter {
                    let containsUsername = $0.username.lowercased().contains(query.lowercased())

                    if let nickname = $0.nickname {
                        let containsNickname = nickname.lowercased().contains(query.lowercased())
                        return containsNickname || containsUsername
                    } else {
                        return containsUsername
                    }
                }
            }
            .map { $0.sorted(by: { ($0.nickname ?? $0.username) < ($1.nickname ?? $1.username) })}
            .sink { [unowned self] in contactsRelay.send($0) }
            .store(in: &cancellables)
    }

    func filter(_ text: String) {
        searchQueryRelay.send(text)
    }
}
