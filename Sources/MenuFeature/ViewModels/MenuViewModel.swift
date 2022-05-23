import Combine
import Defaults
import Foundation
import Integration
import DependencyInjection

final class MenuViewModel {
    @Dependency private var session: SessionType

    @KeyObject(.avatar, defaultValue: nil) var avatar: Data?
    @KeyObject(.username, defaultValue: "") var username: String

    var requestCount: AnyPublisher<Int, Never> {
        Publishers.CombineLatest(
            session.contacts(.received),
            session.groups(.pending)
        ).map { (contacts, groups) in
            let contactRequests = contacts.filter {
                $0.status == .verified ||
                $0.status == .confirming ||
                $0.status == .confirmationFailed ||
                $0.status == .verificationFailed ||
                $0.status == .verificationInProgress
            }

            let groupRequests = groups.filter {
                $0.status == .pending
            }

            return contactRequests.count + groupRequests.count
        }.eraseToAnyPublisher()
    }

    var xxdk: String {
        session.version
    }

    var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
