import Shared
import Combine
import XXModels
import Foundation
import Permissions
import Integration
import DependencyInjection

enum ScanningStatus: Equatable {
    case reading
    case processing
    case success
    case failed(ScanningError)
}

enum ScanningError: Equatable {
    case requestOpened
    case unknown(String)
    case cameraPermission
    case alreadyFriends(String)
}

final class SearchRightViewModel {
    @Dependency var session: SessionType
    @Dependency var permissions: PermissionHandling

    var foundPublisher: AnyPublisher<Contact, Never> {
        foundSubject.eraseToAnyPublisher()
    }

    var cameraSemaphorePublisher: AnyPublisher<Bool, Never> {
        cameraSemaphoreSubject.eraseToAnyPublisher()
    }

    var statusPublisher: AnyPublisher<ScanningStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    private let foundSubject = PassthroughSubject<Contact, Never>()
    private let cameraSemaphoreSubject = PassthroughSubject<Bool, Never>()
    private(set) var statusSubject = CurrentValueSubject<ScanningStatus, Never>(.reading)

    func viewDidAppear() {
        permissions.requestCamera { [weak self] granted in
            guard let self = self else { return }

            if granted {
                self.statusSubject.value = .reading
                self.cameraSemaphoreSubject.send(true)
            } else {
                self.statusSubject.send(.failed(.cameraPermission))
            }
        }
    }

    func viewWillDisappear() {
        cameraSemaphoreSubject.send(false)
    }

    func didScan(data: Data) {
        /// We need to be accepting new readings in order
        /// to process what just got scanned.
        ///
        guard statusSubject.value == .reading else { return }
        statusSubject.send(.processing)

        /// Whatever got scanned, needs to have id and username
        /// otherwise is just noise or an unknown qr code
        ///
        guard let userId = session.getId(from: data),
              let username = try? session.extract(fact: .username, from: data) else {
            let errorTitle = Localized.Scan.Error.invalid
            statusSubject.send(.failed(.unknown(errorTitle)))
            return
        }

        /// Make sure we are not processing a contact
        /// that we already have
        ///
        if let alreadyContact = try? session.dbManager.fetchContacts(.init(id: [userId])).first {
            /// Show error accordingly to the auth status
            ///
            if alreadyContact.authStatus == .friend {
                statusSubject.send(.failed(.alreadyFriends(username)))
            } else if [.requested, .verified].contains(alreadyContact.authStatus) {
                statusSubject.send(.failed(.requestOpened))
            } else {
                let generalErrorTitle = Localized.Scan.Error.general
                statusSubject.send(.failed(.unknown(generalErrorTitle)))
            }

            return
        }

        statusSubject.send(.success)
        cameraSemaphoreSubject.send(false)

        foundSubject.send(.init(
            id: userId,
            marshaled: data,
            username: username,
            email: try? session.extract(fact: .email, from: data),
            phone: try? session.extract(fact: .phone, from: data),
            nickname: nil,
            photo: nil,
            authStatus: .stranger,
            isRecent: false,
            createdAt: Date()
        ))
    }
}
