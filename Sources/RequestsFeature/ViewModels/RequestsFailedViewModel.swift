import HUD
import UIKit
import Models
import Combine
import Integration
import CombineSchedulers
import DependencyInjection

final class RequestsFailedViewModel {
    @Dependency private var session: SessionType

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
        session.dbManager.fetchContactsPublisher(.init(authStatus: [.requestFailed]))
            .assertNoFailure()
            .map { data -> NSDiffableDataSourceSnapshot<Section, Request> in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Request>()
                snapshot.appendSections([.appearing])
                snapshot.appendItems(data.map { Request.contact($0) }, toSection: .appearing)
                return snapshot
            }.sink { [unowned self] in itemsSubject.send($0) }
            .store(in: &cancellables)
    }

    func didTapStateButtonFor(request: Request) {
        guard case let .contact(contact) = request, request.status == .failedToRequest else { return }

        hudSubject.send(.on(nil))
        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.session.retryRequest(contact)
                self.hudSubject.send(.none)
            } catch {
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }
}
