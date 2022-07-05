import Combine
import Foundation

struct SFTPViewState {
    var host: String = ""
    var username: String = ""
    var password: String = ""
    var isButtonEnabled: Bool = false
}

final class SFTPViewModel {
    var statePublisher: AnyPublisher<SFTPViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

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


//        do {
//            let session = try SSH(host: stateSubject.value.host)
//            try session.authenticate(
//                username: stateSubject.value.username,
//                password: stateSubject.value.password
//            )
//
//            let sftp = try session.openSftp()
//            try sftp.download(remotePath: "", localURL: URL(string: "")!)
//        } catch {
//            print(error.localizedDescription)
//        }
    }

    private func validate() {
        stateSubject.value.isButtonEnabled =
        !stateSubject.value.host.isEmpty &&
        !stateSubject.value.username.isEmpty &&
        !stateSubject.value.password.isEmpty
    }
}
