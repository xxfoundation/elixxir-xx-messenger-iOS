import HUD
import UIKit
import Models
import Shared
import Combine
import Integration
import CombineSchedulers
import DependencyInjection

final class RequestsReceivedViewModel {
    @Dependency private var session: SessionType

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    var requests: AnyPublisher<NSDiffableDataSourceSnapshot<SectionId, RequestReceived>, Never> {
        requestsRelay.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)
    private let requestsRelay = CurrentValueSubject<NSDiffableDataSourceSnapshot<SectionId, RequestReceived>, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    // MARK: Lifecycle

    init() {
        Publishers.CombineLatest(session.groups(.pending), session.contacts(.received))
            .map { data -> NSDiffableDataSourceSnapshot<SectionId, RequestReceived> in
                var snapshot = NSDiffableDataSourceSnapshot<SectionId, RequestReceived>()
                let section = SectionId()
                snapshot.appendSections([section])

                let groups = data.0.map { RequestReceived(id: $0.groupId, group: $0, contact: nil) }
                let contacts = data.1.map { RequestReceived(id: $0.userId, group: nil, contact: $0) }

                snapshot.appendItems(groups + contacts, toSection: section)
                return snapshot
            }.sink(
                receiveCompletion: { _ in },
                receiveValue: { [unowned self] in requestsRelay.send($0) }
            ).store(in: &cancellables)
    }

    // MARK: Public

    func didAccept(_ group: Group) {
        hudRelay.send(.on(nil))

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.session.join(group: group)
                self.hudRelay.send(.none)
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    func didAccept(_ contact: Contact) {
        hudRelay.send(.on(nil))

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.session.confirm(contact)
                self.hudRelay.send(.none)
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    func didTapVerification(_ contact: Contact) {
        session.verify(contact: contact)
    }

    func didTapReject(_ request: RequestReceived) {
        guard let contact = request.contact else {
            session.delete(request.group!, isRequest: true)
            return
        }

        session.delete(contact, isRequest: true)
    }
}

struct RequestReceived {
    var id: Data
    var group: Group?
    var contact: Contact?
}

extension RequestReceived: Hashable {}
extension RequestReceived: Equatable {}
