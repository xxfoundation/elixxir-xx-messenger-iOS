import HUD
import Models
import Combine
import Foundation
import SFTPFeature
import DependencyInjection

struct BackupSFTPViewState {
    var host: String = ""
    var username: String = ""
    var password: String = ""
    var isButtonEnabled: Bool = false
}

final class BackupSFTPViewModel {
    @Dependency private var service: SFTPService

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var popPublisher: AnyPublisher<Void, Never> {
        popSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<BackupSFTPViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private let popSubject = PassthroughSubject<Void, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let stateSubject = CurrentValueSubject<BackupSFTPViewState, Never>(.init())

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
        hudSubject.send(.on(nil))

        let host = stateSubject.value.host
        let username = stateSubject.value.username
        let password = stateSubject.value.password

        let authParams = SFTPAuthParams(host, username, password)
        service.justAuthenticate(authParams)
        hudSubject.send(.none)
        popSubject.send(())
    }

    private func validate() {
        stateSubject.value.isButtonEnabled =
        !stateSubject.value.host.isEmpty &&
        !stateSubject.value.username.isEmpty &&
        !stateSubject.value.password.isEmpty
    }
}
