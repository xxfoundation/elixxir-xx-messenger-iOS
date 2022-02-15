import Shared
import XXLogger
import Keychain
import Foundation
import DependencyInjection

public enum NetworkEnvironment {
    case mainnet
}

public protocol XXNetworking {
    var hasClient: Bool { get }

    func writeLogs()
    func purgeFiles()
    func updateErrors()
    func newClient(ndf: String) throws -> Client
    func loadClient(with: Data) throws -> Client
    func updateNDF(_: @escaping (Result<String, Error>) -> Void)
}

public struct XXNetwork<B: BindingsInterface> {
    // MARK: Injected

    @Dependency private var logger: XXLogger
    @Dependency private var keychain: KeychainHandling

    // MARK: Lifecycle

    public init() {}
}

extension XXNetwork: XXNetworking {
    public var hasClient: Bool {
        guard let files = FileManager.xxContents else { return false }
        return files.count > 0
    }

    public func writeLogs() {
        B.listenLogs()
    }

    public func updateErrors() {
        B.updateErrors()
    }

    public func updateNDF(_ completion: @escaping (Result<String, Error>) -> Void) {
        B.updateNDF(for: .mainnet) {
            switch $0 {
            case .success(let data):
                guard let ndfData = data, let ndf = String(data: ndfData, encoding: .utf8) else {
                    completion(.failure(NSError.create("NDF is empty (?)")))
                    return
                }

                completion(.success(ndf))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func purgeFiles() {
        FileManager.xxCleanup()
    }

    public func newClient(ndf: String) throws -> Client {
        var password: Data!

        if hasClient == false {
            var error: NSError?

            password = B.secret(32)
            try keychain.store(password: password)

            _ = B.newClient(ndf, FileManager.xxPath, password, nil, &error)
            if let error = error { throw error }
        } else {
            guard let secret = try keychain.getPassword() else {
                throw NSError.create("Empty stored secret")
            }

            password = secret
        }

        return try loadClient(with: password)
    }

    public func loadClient(with secret: Data) throws -> Client {
        var error: NSError?
        let bindings = B.login(FileManager.xxPath, secret, "", &error)
        if let error = error { throw error }

        if let defaults = UserDefaults(suiteName: "group.io.xxlabs.notification") {
            defaults.set(bindings!.receptionId.base64EncodedString(), forKey: "receptionId")
        }

        return Client(bindings!)
    }
}


extension NetworkEnvironment {
    var url: String {
        switch self {
        case .mainnet:
            return "https://elixxir-bins.s3.us-west-1.amazonaws.com/ndf/mainnet.json"
        }
    }

    var cert: String {
        switch self {
        case .mainnet:
            guard let filepath = Bundle.module.path(forResource: "cert_mainnet", ofType: "txt"),
                  let certString = try? String(contentsOfFile: filepath) else {
                      fatalError("Couldn't retrieve network cert file.")
                  }

            return certString
        }
    }
}
