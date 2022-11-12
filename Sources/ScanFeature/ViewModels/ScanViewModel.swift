import Shared
import Combine
import XXModels
import XXClient
import Foundation
import ReportingFeature
import DI

enum ScanStatus: Equatable {
    case reading
    case processing
    case success
    case failed(ScanError)
}

enum ScanError: Equatable {
    case requestOpened
    case unknown(String)
    case cameraPermission
    case alreadyFriends(String)
}

final class ScanViewModel {
    @Dependency var database: Database
    @Dependency var reportingStatus: ReportingStatus

    var contactPublisher: AnyPublisher<XXModels.Contact, Never> {
        contactSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<ScanStatus, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private let contactSubject = PassthroughSubject<XXModels.Contact, Never>()
    private let stateSubject = CurrentValueSubject<ScanStatus, Never>(.reading)

    func resetScanner() {
        stateSubject.send(.reading)
    }

    func didScanData(_ data: Data) {
        guard stateSubject.value == .reading else { return }
        stateSubject.send(.processing)

        let user = XXClient.Contact.live(data)

        guard let uid = try? user.getId(),
              let facts = try? user.getFacts(),
              let username = facts.first(where: { $0.type == .username })?.value else {
            let errorTitle = Localized.Scan.Error.invalid
            stateSubject.send(.failed(.unknown(errorTitle)))
            return
        }

        let email = facts.first { $0.type == .email }?.value
        let phone = facts.first { $0.type == .phone }?.value

        if let alreadyContact = try? database.fetchContacts(.init(id: [uid])).first {
            if alreadyContact.isBlocked, reportingStatus.isEnabled() {
                stateSubject.send(.failed(.unknown("You previously blocked this user.")))
                return
            }

            if alreadyContact.isBanned, reportingStatus.isEnabled() {
                stateSubject.send(.failed(.unknown("This user was banned.")))
                return
            }

            if alreadyContact.authStatus == .friend {
                stateSubject.send(.failed(.alreadyFriends(username)))
            } else if [.requested, .verified].contains(alreadyContact.authStatus) {
                stateSubject.send(.failed(.requestOpened))
            } else {
                let generalErrorTitle = Localized.Scan.Error.general
                stateSubject.send(.failed(.unknown(generalErrorTitle)))
            }

            return
        }

        stateSubject.send(.success)
        contactSubject.send(.init(
            id: uid,
            marshaled: data,
            username: username,
            email: email,
            phone: phone,
            nickname: nil,
            photo: nil,
            authStatus: .stranger,
            isRecent: false,
            createdAt: Date()
        ))
    }
}
