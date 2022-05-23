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

    func updateNDF(
        _: @escaping (Result<String, Error>) -> Void
    )

    func loadClient(
        with: Data,
        fromBackup: Bool,
        email: String?,
        phone: String?
    ) throws -> Client

    func newClientFromBackup(
        passphrase: String,
        data: Data,
        ndf: String
    ) throws -> (Client, Data?)
}

public struct XXNetwork<B: BindingsInterface> {
    @Dependency private var logger: XXLogger
    @Dependency private var keychain: KeychainHandling

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

    public func newClientFromBackup(
        passphrase: String,
        data: Data,
        ndf: String
    ) throws -> (Client, Data?) {
        var error: NSError?

        let password = B.secret(32)!
        try keychain.store(password: password)

        let backupData = B.fromBackup(
            ndf,
            FileManager.xxPath,
            password,
            "\(passphrase)".data(using: .utf8),
            data,
            &error
        )

        if let error = error { throw error }

        var email: String?
        var phone: String?

        let report = try! JSONDecoder().decode(BackupReport.self, from: backupData!)

        if !report.parameters.isEmpty {
            let params = try! JSONDecoder().decode(BackupParameters.self, from: Data(report.parameters.utf8))
            phone = params.phone
            email = params.email
        }

        let client = try loadClient(with: password, fromBackup: true, email: email, phone: phone)
        return (client, backupData)
    }

    public func newClient(ndf: String) throws -> Client {
        var password: Data!

        if hasClient == false {
            var error: NSError?

            password = B.secret(32)
            try keychain.store(password: password)

            _ = B.new(ndf, FileManager.xxPath, password, nil, &error)
            if let error = error { throw error }
        } else {
            guard let secret = try keychain.getPassword() else {
                throw NSError.create("Empty stored secret")
            }

            password = secret
        }

        return try loadClient(with: password, fromBackup: false, email: nil, phone: nil)
    }

    public func loadClient(
        with secret: Data,
        fromBackup: Bool,
        email: String?,
        phone: String?
    ) throws -> Client {
        var error: NSError?
        let bindings = B.login(FileManager.xxPath, secret, "", &error)
        if let error = error { throw error }

        if let defaults = UserDefaults(suiteName: "group.io.xxlabs.notification") {
            defaults.set(bindings!.receptionId.base64EncodedString(), forKey: "receptionId")
        }

        return Client(bindings!, fromBackup: fromBackup, email: email, phone: phone)
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
