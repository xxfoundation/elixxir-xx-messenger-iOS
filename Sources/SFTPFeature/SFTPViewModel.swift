import HUD
import Combine
import Foundation
import DependencyInjection

struct SFTPViewState {
    var host: String = ""
    var username: String = ""
    var password: String = ""
    var isButtonEnabled: Bool = false
}

final class SFTPViewModel {
    @Dependency private var service: SFTPService

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<SFTPViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var authPublisher: AnyPublisher<Void, Never> {
        authSubject.eraseToAnyPublisher()
    }

    private let authSubject = PassthroughSubject<Void, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let stateSubject = CurrentValueSubject<SFTPViewState, Never>(.init())

    func didEnterHost(_ string: String) {
        stateSubject.value.host = string
        validate()
    }

    func didEnterUsername(_ string: String) {
        stateSubject.value.username = string
        validate()
    }

    func didEnterPassword(_ string: String) {
        stateSubject.value.password = string
        validate()
    }

    func didTapLogin() {
        hudSubject.send(.on)

        let host = stateSubject.value.host
        let username = stateSubject.value.username
        let password = stateSubject.value.password

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                try self.service.authenticate(
                    host: host,
                    username: username,
                    password: password
                )

                self.hudSubject.send(.none)
                self.authSubject.send(())
            } catch {
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    private func validate() {
        stateSubject.value.isButtonEnabled =
        !stateSubject.value.host.isEmpty &&
        !stateSubject.value.username.isEmpty &&
        !stateSubject.value.password.isEmpty
    }
}
