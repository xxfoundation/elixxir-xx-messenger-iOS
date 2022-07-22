import HUD
import UIKit
import Models
import Shared
import Combine
import XXModels
import Integration
import ToastFeature
import CombineSchedulers
import DependencyInjection

struct RequestSent: Hashable, Equatable {
    var request: Request
    var isResent: Bool = false
}

final class RequestsSentViewModel {
    @Dependency private var session: SessionType
    @Dependency private var toastController: ToastController

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var itemsPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<Section, RequestSent>, Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let itemsSubject = CurrentValueSubject<NSDiffableDataSourceSnapshot<Section, RequestSent>, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    init() {
        let query = Contact.Query(authStatus: [
            .requested,
            .requesting
        ])

        session.dbManager.fetchContactsPublisher(query)
            .assertNoFailure()
            .removeDuplicates()
            .map { data -> NSDiffableDataSourceSnapshot<Section, RequestSent> in
                var snapshot = NSDiffableDataSourceSnapshot<Section, RequestSent>()
                snapshot.appendSections([.appearing])
                snapshot.appendItems(data.map { RequestSent(request: .contact($0)) }, toSection: .appearing)
                return snapshot
            }.sink { [unowned self] in itemsSubject.send($0) }
            .store(in: &cancellables)
    }

    func didTapStateButtonFor(request item: RequestSent) {
        guard case let .contact(contact) = item.request, item.request.status == .requested else { return }

        hudSubject.send(.on)
        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.session.retryRequest(contact)
                self.hudSubject.send(.none)

                var item = item
                var allRequests = self.itemsSubject.value.itemIdentifiers

                if let indexOfRequest = allRequests.firstIndex(of: item) {
                    allRequests.remove(at: indexOfRequest)
                }

                item.isResent = true
                allRequests.append(item)

                let name = (contact.nickname ?? contact.username) ?? ""

                self.toastController.enqueueToast(model: .init(
                    title: Localized.Requests.Sent.Toast.resent(name),
                    leftImage: Asset.requestSentToaster.image
                ))

                var snapshot = NSDiffableDataSourceSnapshot<Section, RequestSent>()
                snapshot.appendSections([.appearing])
                snapshot.appendItems(allRequests, toSection: .appearing)
                self.itemsSubject.send(snapshot)
            } catch {
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }
}
