import HUD
import Models
import Combine
import Foundation
import SFTPFeature
import DependencyInjection

struct RestoreSFTPViewState {
    var host: String = ""
    var username: String = ""
    var password: String = ""
    var isButtonEnabled: Bool = false
}

final class RestoreSFTPViewModel {
    @Dependency private var service: SFTPService

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var backupPublisher: AnyPublisher<RestoreSettings, Never> {
        backupSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<RestoreSFTPViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let backupSubject = PassthroughSubject<RestoreSettings, Never>()
    private let stateSubject = CurrentValueSubject<RestoreSFTPViewState, Never>(.init())

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

        let completion: SFTPFetchResult = { result in
            switch result {
            case .success(let backup):
                self.hudSubject.send(.none)

                if let backup = backup {
                    self.backupSubject.send(backup)
                } else {
                    self.backupSubject.send(.init(cloudService: .sftp))
                }
            case .failure(let error):
                self.hudSubject.send(.error(.init(with: error)))
            }
        }

        let authParams = SFTPAuthParams(host, username, password)
        service.fetch((authParams, completion))
    }

    private func validate() {
        stateSubject.value.isButtonEnabled =
        !stateSubject.value.host.isEmpty &&
        !stateSubject.value.username.isEmpty &&
        !stateSubject.value.password.isEmpty
    }
}
