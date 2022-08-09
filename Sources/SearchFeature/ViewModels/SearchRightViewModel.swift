import Shared
import Models
import Combine
import XXModels
import Defaults
import XXClient
import Foundation
import Permissions
import ReportingFeature
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
    @Dependency var database: Database
    @Dependency var permissions: PermissionHandling
    @Dependency var reportingStatus: ReportingStatus
    @Dependency var getFactsFromContact: GetFactsFromContact

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

    func viewWillAppear() {
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
        let userId = try? GetIdFromContact.live(data)
        let facts = try? getFactsFromContact(contact: data)
        let username = facts?.first(where: { $0.type == FactType.username.rawValue })?.fact

        guard let userId = userId, let username = username else {
            let errorTitle = Localized.Scan.Error.invalid
            statusSubject.send(.failed(.unknown(errorTitle)))
            return
        }

        /// Make sure we are not processing a contact
        /// that we already have
        ///
        if let alreadyContact = try? database.fetchContacts(.init(id: [userId])).first {
            if alreadyContact.isBlocked, reportingStatus.isEnabled() {
                statusSubject.send(.failed(.unknown("You previously blocked this user.")))
                return
            }

            if alreadyContact.isBanned, reportingStatus.isEnabled() {
                statusSubject.send(.failed(.unknown("This user was banned.")))
                return
            }

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

        let email = try? GetFactsFromContact.live(contact: data)
            .first(where: { $0.type == FactType.email.rawValue })
            .map(\.fact)

        let phone = try? GetFactsFromContact.live(contact: data)
            .first(where: { $0.type == FactType.phone.rawValue })
            .map(\.fact)

        foundSubject.send(.init(
            id: userId,
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
