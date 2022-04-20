import HUD
import Combine
import Models
import Integration
import DifferenceKit
import DependencyInjection
import CombineSchedulers

final class RequestsSentViewModel {
    // MARK: Injected

    @Dependency private var session: SessionType

    // MARK: Properties

    var items: AnyPublisher<[Contact], Never> {
        relay.eraseToAnyPublisher()
    }

    var hud: AnyPublisher<HUDStatus, Never> {
        hudRelay.eraseToAnyPublisher()
    }


    private var cancellables = Set<AnyCancellable>()
    private let relay = CurrentValueSubject<[Contact], Never>([])
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    // MARK: Lifecycle

    init() {
        session.contacts(.requested)
            .sink { [unowned self] in relay.send($0) }
            .store(in: &cancellables)
    }

    func didTapResend(_ contact: Contact) {
        hudRelay.send(.on(nil))

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.session.retryRequest(contact)
                self.hudRelay.send(.none)
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }
}
