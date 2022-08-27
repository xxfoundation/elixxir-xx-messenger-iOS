import Shared
import Models
import Combine
import XXModels
import Foundation
import XXClient
import CombineSchedulers
import DependencyInjection

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

struct ScanViewState: Equatable {
    var status: ScanStatus = .reading
}

final class ScanViewModel {
    @Dependency var database: Database
    @Dependency var getFactsFromContact: GetFactsFromContact

    var backgroundScheduler: AnySchedulerOf<DispatchQueue>
        = DispatchQueue.global().eraseToAnyScheduler()

    var contactPublisher: AnyPublisher<XXModels.Contact, Never> { contactRelay.eraseToAnyPublisher() }
    private let contactRelay = PassthroughSubject<XXModels.Contact, Never>()

    var state: AnyPublisher<ScanViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<ScanViewState, Never>(.init())

    func resetScanner() {
        stateRelay.value.status = .reading
    }

    func didScanData(_ data: Data) {
        guard stateRelay.value.status == .reading else { return }
        stateRelay.value.status = .processing

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                guard let usernameAndId = try self.verifyScanned(data) else {
                    self.stateRelay.value.status = .failed(.unknown(Localized.Scan.Error.general))
                    return
                }



                if let previouslyAdded = try? self.database.fetchContacts(.init(id: [usernameAndId.1])).first {
                    var error = ScanError.unknown(Localized.Scan.Error.general)

                    switch previouslyAdded.authStatus {
                    case .friend:
                        error = .alreadyFriends(usernameAndId.0)
                    case .requested, .verified:
                        error = .requestOpened
                    default:
                        break
                    }

                    self.stateRelay.value.status = .failed(error)
                    return
                }

                let facts = try? self.getFactsFromContact(data)
                let contactEmail = facts?.first(where: { $0.type == FactType.email.rawValue })?.fact
                let contactPhone = facts?.first(where: { $0.type == FactType.phone.rawValue })?.fact

                let contact = Contact(
                    id: usernameAndId.1,
                    marshaled: data,
                    username: usernameAndId.0,
                    email: contactEmail,
                    phone: contactPhone,
                    nickname: nil,
                    photo: nil,
                    authStatus: .stranger,
                    isRecent: false,
                    createdAt: Date()
                )

                self.succeed(with: contact)
            } catch {
                self.stateRelay.value.status = .failed(.unknown(Localized.Scan.Error.invalid))
            }
        }
    }

    private func verifyScanned(_ data: Data) throws -> (String, Data)? {
        let id = try? GetIdFromContact.live(data)
        let facts = try? getFactsFromContact(data)
        let username = facts?.first(where: { $0.type == FactType.username.rawValue })?.fact

        guard let id = id, let username = username else { return nil }
        return (username, id)
    }

    private func succeed(with contact: XXModels.Contact) {
        stateRelay.value.status = .success
        contactRelay.send(contact)
    }
}
