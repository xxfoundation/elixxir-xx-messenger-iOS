import Shared
import Models
import Combine
import Foundation
import Integration
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
    @Dependency private var session: SessionType

    var backgroundScheduler: AnySchedulerOf<DispatchQueue>
        = DispatchQueue.global().eraseToAnyScheduler()

    var contactPublisher: AnyPublisher<Contact, Never> { contactRelay.eraseToAnyPublisher() }
    private let contactRelay = PassthroughSubject<Contact, Never>()

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

                if let previouslyAdded = self.session.find(by: usernameAndId.0) {
                    var error = ScanError.unknown(Localized.Scan.Error.general)

                    switch previouslyAdded.status {
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

                let contact = Contact(
                    photo: nil,
                    userId: usernameAndId.1,
                    email: try? self.session.extract(fact: .email, from: data),
                    phone: try? self.session.extract(fact: .phone, from: data),
                    status: .stranger,
                    marshaled: data,
                    username: usernameAndId.0,
                    nickname: nil,
                    createdAt: Date(),
                    isRecent: false
                )

                self.succeed(with: contact)
            } catch {
                self.stateRelay.value.status = .failed(.unknown(Localized.Scan.Error.invalid))
            }
        }
    }

    private func verifyScanned(_ data: Data) throws -> (String, Data)? {
        guard let username = try session.extract(fact: .username, from: data),
                let id = session.getId(from: data) else { return nil }

        return (username, id)
    }

    private func succeed(with contact: Contact) {
        stateRelay.value.status = .success
        contactRelay.send(contact)
    }
}
