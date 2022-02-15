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
        ).map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
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
