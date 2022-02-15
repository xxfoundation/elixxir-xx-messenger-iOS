import Combine
import Foundation

#warning("TODO: Unit test this feature")

public enum VersionInfo {
    case upToDate
    case failure(Error)
    case updateRequired(DappVersionInformation)
    case updateRecommended(DappVersionInformation)
}

public struct VersionDataFetcher {
    var run: () -> AnyPublisher<DappVersionInformation, Error>

    public init(run: @escaping () -> AnyPublisher<DappVersionInformation, Error>) {
        self.run = run
    }

    public func callAsFunction() -> AnyPublisher<DappVersionInformation, Error> { run() }
}

public struct VersionChecker {
    var run: () -> AnyPublisher<VersionInfo, Never>

    public init(run: @escaping () -> AnyPublisher<VersionInfo, Never>) {
        self.run = run
    }

    public func callAsFunction() -> AnyPublisher<VersionInfo, Never> { run() }
}

public extension VersionChecker {

    static let mock: Self = .init { Just(.upToDate).eraseToAnyPublisher() }

    static func live(
        fetchVersion: VersionDataFetcher = .live(),
        bundleVersion: @escaping () -> String = { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String }
    ) -> Self {
        .init {
            fetchVersion()
                .map { dappInfo -> VersionInfo in
                    let version = bundleVersion()
                    if version >= dappInfo.recommended {
                        return .upToDate
                    } else if version >= dappInfo.minimum {
                        return .updateRecommended(dappInfo)
                    } else {
                        return .updateRequired(dappInfo)
                    }
                }
                .catch { Just(VersionInfo.failure($0)) }
                .eraseToAnyPublisher()
        }
    }
}

public extension VersionDataFetcher {
    static func mock() -> Self {
        .init {
            Just(DappVersionInformation(
                appUrl: "https://testflight.apple.com/join/L1Rj0so3",
                minimum: "1.0",
                recommended: "1.0",
                minimumMessage: "This app version is not supported anymore, please update to the latest version to keep enjoying our app"
            ))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    static func live() -> Self {
        .init {
            let request = URLRequest(
                url: URL(string: "https://elixxir-bins.s3-us-west-1.amazonaws.com/client/dapps/appdb.json")!,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: 5
            )

            return URLSession.shared
                .dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: BackendVersionInformation.self, decoder: JSONDecoder())
                .map(\.info)
                .eraseToAnyPublisher()
        }
    }
}

public struct DappVersionInformation: Codable {
    public let appUrl: String
    public let minimum: String
    public let recommended: String
    public let minimumMessage: String

    private enum CodingKeys: String, CodingKey {
        case appUrl = "new_ios_app_url"
        case minimum = "new_ios_min_version"
        case recommended = "new_ios_recommended_version"
        case minimumMessage = "new_minimum_popup_msg"
    }
}

private struct BackendVersionInformation: Codable {
    let info: DappVersionInformation

    private enum CodingKeys: String, CodingKey {
        case info = "dapp-id"
    }
}
