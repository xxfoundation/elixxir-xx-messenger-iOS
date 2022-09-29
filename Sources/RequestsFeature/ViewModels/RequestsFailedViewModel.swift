import HUD
import UIKit
import Models
import Combine
import XXModels
import Defaults
import XXClient
import CombineSchedulers
import DependencyInjection
import XXMessengerClient

final class RequestsFailedViewModel {
    @Dependency var database: Database
    @Dependency var messenger: Messenger

    @KeyObject(.username, defaultValue: nil) var username: String?
    @KeyObject(.sharingEmail, defaultValue: false) var sharingEmail: Bool
    @KeyObject(.sharingPhone, defaultValue: false) var sharingPhone: Bool

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var itemsPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<Section, Request>, Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let itemsSubject = CurrentValueSubject<NSDiffableDataSourceSnapshot<Section, Request>, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    init() {
        database.fetchContactsPublisher(.init(authStatus: [.requestFailed, .confirmationFailed]))
        .replaceError(with: [])
            .map { data -> NSDiffableDataSourceSnapshot<Section, Request> in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Request>()
                snapshot.appendSections([.appearing])
                snapshot.appendItems(data.map { Request.contact($0) }, toSection: .appearing)
                return snapshot
            }.sink { [unowned self] in itemsSubject.send($0) }
            .store(in: &cancellables)
    }

    func didTapStateButtonFor(request: Request) {
        guard case var .contact(contact) = request,
                request.status == .failedToRequest ||
                request.status == .failedToConfirm else {
            return
        }

        hudSubject.send(.on)
        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                if request.status == .failedToRequest {

                    var includedFacts: [Fact] = []
                    let myFacts = try self.messenger.ud.get()!.getFacts()

                    if let fact = myFacts.get(.username) {
                        includedFacts.append(fact)
                    }

                    if self.sharingEmail, let fact = myFacts.get(.email) {
                        includedFacts.append(fact)
                    }

                    if self.sharingPhone, let fact = myFacts.get(.phone) {
                        includedFacts.append(fact)
                    }

                    let _ = try self.messenger.e2e.get()!.requestAuthenticatedChannel(
                        partner: .live(contact.marshaled!),
                        myFacts: includedFacts
                    )

                    contact.authStatus = .requested
                } else {
                    let _ = try self.messenger.e2e.get()!.confirmReceivedRequest(
                        partner: XXClient.Contact.live(contact.marshaled!)
                    )

                    contact.authStatus = .friend
                }

                try self.database.saveContact(contact)
                self.hudSubject.send(.none)
            } catch {
                let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
                self.hudSubject.send(.error(.init(content: xxError)))
            }
        }
    }
}
