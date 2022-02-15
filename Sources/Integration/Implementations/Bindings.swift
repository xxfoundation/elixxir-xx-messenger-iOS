import Shared
import Models
import Bindings
import DependencyInjection
import Foundation

public let evaluateNotification: NotificationEvaluation = BindingsNotificationsForMe

public protocol NotificationReportProtocol {
    func forMe() -> Bool
    func type() -> String
}

public protocol NotificationManyReportProtocol {
    func len() -> Int
    func get(index: Int) throws -> NotificationReportProtocol
}

extension BindingsNotificationForMeReport: NotificationReportProtocol {}

extension BindingsManyNotificationForMeReport: NotificationManyReportProtocol {
    public func get(index: Int) throws -> NotificationReportProtocol {
        try get(index)
    }
}

extension BindingsClient: BindingsInterface {
    public func removeContact(_ data: Data) throws {
        do {
            try deleteContact(data)
            log(string: "Deleted a contact", type: .info)
        } catch {
            log(string: "Failed to delete a contact: \(error.localizedDescription)", type: .error)
            throw error.friendly()
        }
    }

    func dumpThreads() {
        log(type: .crumbs)

        var error: NSError?
        let string = BindingsDumpStack(&error)

        if let error = error {
            log(string: error.localizedDescription, type: .error)
            return
        }

        log(string: string, type: .bindings)
    }

    public func verify(marshaled: Data, verifiedMarshaled: Data) throws -> Bool {
        var bool: ObjCBool = false
        try verifyOwnership(marshaled, verifiedMarshaled: verifiedMarshaled, ret0_: &bool)
        log(string: "Onwership verification: \(bool.boolValue)", type: bool.boolValue ? .info : .error)
        return bool.boolValue
    }

    public func compress(
        image: Data,
        _ completion: @escaping(Result<Data, Error>) -> Void
    ) {
        var error: NSError?
        let compressed = BindingsCompressJpeg(image, &error)

        guard error == nil else {
            log(string: "Error when compressing jpeg: \(error!.localizedDescription)", type: .error)
            completion(.failure(error!.friendly()))
            return
        }

        guard let compressed = compressed else {
            let extensiveLog =
            """
            #### Important: No error was written but CompressJpeg() returned nothing.
            - Params:
            -- imageData = \(image.base64EncodedString())
            - Error description: \(error!.localizedDescription)
            """
            log(string: extensiveLog, type: .error)
            log(string: "An image compression failed without any specific error", type: .error)
            completion(.failure(NSError.create("Image compression failed without error")))
            return
        }

        let compressionRate = String(format: "%.4f", Float(compressed.count)/Float(image.count))
        log(string: "Compressed image x\(compressionRate) (\(image.count) -> \(compressed.count))", type: .info)
        completion(.success(compressed))
    }

    public var hasRunningTasks: Bool {
        hasRunningProcessies()
    }

    public var myId: Data {
        guard let user = getUser(), let contact = user.getContact(), let id = contact.getID() else {
            fatalError("Couldn't get my ID")
        }

        return id
    }

    public var meMarshalled: Data {
        guard let user = getUser(), let contact = user.getContact(), let marshal = try? contact.marshal() else {
            fatalError("Couldn't get my own contact marshalled")
        }

        return marshal
    }

    public func getPreImages() -> String {
        getPreimages(receptionId)
    }

    public func meMarshalled(_ username: String, email: String?, phone: String?) -> Data {
        guard let user = getUser(), let contact = user.getContact(), let factList = contact.getFactList() else {
            let extensiveLog =
            """
            #### Important: It was impossible to get the fact list of my own contact.
            - getUser was nil? = \(getUser() == nil)
            - getContact was nil? = \(getUser()?.getContact() == nil)
            """
            log(string: extensiveLog, type: .error)
            dumpThreads()
            fatalError(extensiveLog)
        }

        do {
            try factList.add(username, factType: FactType.username.rawValue)
        } catch {
            log(string: error.localizedDescription, type: .error)
            dumpThreads()
            fatalError()
        }

        if let email = email {
            do {
                try factList.add(email, factType: FactType.email.rawValue)
            } catch {
                log(string: error.localizedDescription, type: .error)
                dumpThreads()
                fatalError()
            }
        }

        if let phone = phone {
            do {
                try factList.add(phone, factType: FactType.phone.rawValue)
            } catch {
                log(string: error.localizedDescription, type: .error)
                dumpThreads()
                fatalError()
            }
        }

        do {
            return try contact.marshal()
        } catch {
            log(string: error.localizedDescription, type: .error)
            dumpThreads()
            fatalError()
        }
    }

    public var receptionId: Data {
        guard let user = getUser(), let recId = user.getReceptionID() else {
            let extendedLog =
            """
            #### Important: It was impossible to get my own reception id.
            - getUser was nil? = \(getUser() == nil)
            """
            log(string: extendedLog, type: .error)
            dumpThreads()
            fatalError(extendedLog)
        }

        return recId
    }

    public static let version: String = {
        return BindingsGetVersion()
    }()

    public static let secret: (Int) -> Data? = BindingsGenerateSecret

    public static let login: (String?, Data?, String?, NSErrorPointer) -> BindingsInterface? = BindingsLogin

    public static let newClient: (String?, String?, Data?, String?, NSErrorPointer) -> Bool = BindingsNewClient

    public static func updateNDF(
        for env: NetworkEnvironment,
        _ completion: @escaping (Result<Data?, Error>) -> Void
    ) {
        log(type: .crumbs)

        var error: NSError?
        let ndf = BindingsDownloadAndVerifySignedNdfWithUrl(env.url, env.cert, &error)

        if let error = error {
            log(string: error.localizedDescription, type: .error)
            completion(.failure(error))
        } else {
            completion(.success(ndf))
        }
    }

    /// Fetches a JSON with up-to-date error descriptions
    /// then passes it to the bindings that will emit cleaner
    /// errors
    ///
    /// - ToDo: Request status codes for errors
    ///
    public static func updateErrors() {
        log(type: .crumbs)

        var error: NSError?
        if let dbErrors = BindingsDownloadErrorDB(&error) {
            var otherError: NSError?
            BindingsUpdateCommonErrors(String(data: dbErrors, encoding: .utf8), &otherError)

            if let otherError = otherError {
                log(string: otherError.localizedDescription, type: .error)
            }
        }

        if let error = error {
            log(string: error.localizedDescription, type: .error)
        }
    }

    /// Starts the network
    ///
    /// If network status is != 0 it means the network is
    /// not ready yet or the device is not ready. A recursion was applied
    /// as a temporary solution in order to retry indefinitely
    ///
    /// - ToDo: Split function into smaller functions
    ///
    public func startNetwork() {
        log(type: .crumbs)

        var error: NSError?
        let status = networkFollowerStatus()

        BindingsLogLevel(1, &error)
        registerErrorCallback(BindingsError())

        guard status == 0 else {
            log(string: "Network is not ready yet. Let's give it a second...", type: .error)
            sleep(1)
            startNetwork()
            return
        }

        try! startNetworkFollower(10000)
        log(string: "Starting the network...", type: .info)
    }

    /// (Tries) to stop the network
    ///
    /// - Warning: This function tries to stop several
    ///            threads and it may take some time.
    ///            That's why we register a background
    ///            task on AppDelegate.swift
    ///
    public func stopNetwork() {
        log(type: .crumbs)

        try! stopNetworkFollower()
        log(string: "Stopping the network...", type: .info)
    }

    /// Extracts *user id* from a contact
    ///
    /// - Parameters:
    ///   - from: Byte array containing contact object
    ///
    /// - Returns: Optional byte array, if *user id* could be retrieved
    ///
    public func getId(from marshaled: Data) -> Data? {
        log(type: .crumbs)

        var error: NSError?
        let contact = BindingsUnmarshalContact(marshaled, &error)

        if let error = error {
            log(string: error.localizedDescription, type: .error)
            return nil
        }

        return contact?.getID()
    }

    public func add(_ contact: Data, from me: Data, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        log(type: .crumbs)

        do {
            var roundId = Int()
            try requestAuthenticatedChannel(contact, meMarshaled: me, message: nil, ret0_: &roundId)
            completion(.success(true))
        } catch {
            log(string: error.localizedDescription, type: .error)
            completion(.failure(error.friendly()))
        }
    }

    /// Confirms a contact request
    ///
    /// - Parameters:
    ///   - contact: Byte array containing *contact object*
    ///   - completion: Result callback with associated
    ///                 values *boolean* = success &&
    ///                 !timedOut or *Error* upon throwing
    ///
    public func confirm(_ contact: Data, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        log(type: .crumbs)

        do {
            var roundId = Int()
            try confirmAuthenticatedChannel(contact, ret0_: &roundId)
            completion(.success(true))
        } catch {
            log(string: error.localizedDescription, type: .error)
            completion(.failure(error.friendly()))
        }
    }

    /// Sends a message over CMIX
    ///
    /// - Parameters:
    ///   - recipient: Byte array containing *user id*
    ///   - payload: Byte array containing *message payload*
    ///
    /// - Returns: Result w/ associated values
    ///            byte array containing *SentReport*
    ///            or *Error* upon throwing
    ///
    public func send(_ payload: Data, to recipient: Data) -> Result<E2ESendReportType, Error> {
        log(type: .crumbs)

        do {
            let report = try sendE2E(recipient, payload: payload, messageType: 2, parameters: nil)

            var roundIds = [Int]()

            if let roundList = report.getRoundList(), let payloadUnwrapped = try? Payload(with: payload) {
                let length = roundList.len()
                for index in 0..<length {
                    var integer: Int = 0
                    do {
                        try roundList.get(index, ret0_: &integer)
                        roundIds.append(integer)
                    } catch {
                        log(string: "Error trying to inspect round list: \(error.localizedDescription)", type: .error)
                    }
                }

                log(string: "Round ids for \(payloadUnwrapped.text.prefix(5))... = \(roundIds)", type: .info)
            }

            return .success(report)
        } catch {
            log(string: error.localizedDescription, type: .error)
            return .failure(error)
        }
    }

    /// Listens to the delivery of a message through a report
    ///
    /// - Note: Delivery actually refers to the
    ///         gateway, not necessarily the other end
    ///         received/read this message yet.
    ///
    /// - Parameters:
    ///   - report: SentReport marshalled
    ///   - completion: Result callback w/ associated
    ///                 values *completed* or *Error*
    ///                 upon throwing
    ///
    public func listen(report: Data, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            try listenDelivery(of: report) { msgId, delivered, timedOut, roundResults in
                if delivered == false {
                    let extendedLogs =
                    """
                    Round delivery callback from wait(forMessageDelivery:)
                    - timedOut = \(timedOut)
                    - delivered = \(delivered)
                    """
                    log(string: extendedLogs, type: .error)
                    log(string: extendedLogs, type: .error)
                }

                completion(.success(delivered))
            }
        } catch {
            completion(.failure(error))
        }
    }

    /// Registers device token on backend for push notifications
    ///
    /// - Parameters:
    ///   - string: Device token provided by APNS
    ///
    /// - Throws: If an exception was raised on
    ///           backend such as timing out
    ///
    public func registerNotifications(_ token: String) throws {
        log(type: .crumbs)

        do {
            try register(forNotifications: token)
            log(string: "Registered for notifications using token: \(token)", type: .info)
        } catch {
            log(string: error.localizedDescription, type: .error)
            throw error.friendly()
        }
    }

    /// Unregisters device token on backend
    ///
    /// - Throws: If when trying to unregister
    ///           some exception come up such as
    ///           timing out or user is not registered
    ///
    public func unregisterNotifications() throws {
        log(type: .crumbs)

        do {
            try unregisterForNotifications()
            log(string: "Unregistered notifications", type: .info)
        } catch {
            log(string: error.localizedDescription, type: .error)
            throw error.friendly()
        }
    }

    /// Checks if number of nodes already registered is enough
    ///
    /// Whenever the user wants to do an operation that involves
    /// *User Discovery*, the app should make sure that a minimum
    /// amount of nodes already know about this user
    ///
    /// - Throws: `NodeRegistrationError.amountIsTooLow` if
    ///            the ratio is below minimum (currently 85%).
    ///            `NodeRegistrationError.networkIsNotHealthyYet`
    ///            when trying to fetch registration status and
    ///            network is not healthy yet
    ///
    public func nodeRegistrationStatus() throws {
        log(type: .crumbs)

        enum NodeRegistrationError: Error {
            case amountIsTooLow
        }

        var shortRatio: String?

        do {
            let status = try getNodeRegistrationStatus()
            let registered = Float(status.getRegistered())
            let total = Float(status.getTotal())
            let ratio = Float(registered/total)

            let nf = NumberFormatter()
            nf.roundingMode = .down
            nf.maximumFractionDigits = 2
            nf.numberStyle = .percent
            shortRatio = nf.string(from: NSNumber(value: ratio))

            guard ratio >= 0.85 else { throw NodeRegistrationError.amountIsTooLow }
            log(string: "Node registration rate: \(shortRatio ?? "")", type: .info)
        } catch NodeRegistrationError.amountIsTooLow {

            let string = "Node registration rate is still below 85% (\(shortRatio ?? ""))"
            log(string: string, type: .error)

            let userError = "We are still establishing a secure registration with the decentralized network. Please try again in a few seconds."

            throw NSError.create(userError)
        } catch {
            log(string: error.localizedDescription, type: .error)
            throw error
        }
    }

    /// Instantiates a transfer manager
    ///
    /// - Returns: An instance of *BindingsFileTransfer (TransferManager)*
    ///
    /// - Throws: `FTError.noInstance` if no error was thrown
    ///            but also no instance was created
    ///
    public func generateTransferManager(
        _ callback: @escaping (Data, String?, String?, Data?) -> Void
    ) throws -> TransferManagerInterface {
        log(type: .crumbs)

        let incomingTransferCallback = IncomingTransferCallback { tid, name, type, sender, size, preview in
            guard let tid = tid else { fatalError("An incoming transfer has no TID?") }

            callback(tid, name, type, sender)
        }

        var error: NSError?
        let manager = BindingsNewFileTransferManager(self, incomingTransferCallback, "", &error)

        guard let error = error else { return manager! }
        throw error.friendly()
    }

    public func generateDummyTraficManager() throws -> DummyTrafficManaging {
        var error: NSError?
        let manager = BindingsNewDummyTrafficManager(self, 5, 30000, 25000, &error)

        guard let error = error else { return manager! }
        throw error.friendly()
    }

    /// Instantiates user discovery
    ///
    /// - Returns: An instance of *UD (User discovery)*
    ///
    /// - Throws: `UDError.noInstance` if no error was thrown
    ///            but also no instance was created
    ///
    public func generateUD() throws -> UserDiscoveryInterface {
        log(type: .crumbs)

        var error: NSError?
        let udb = BindingsNewUserDiscovery(self, &error)

        guard let error = error else { return udb! }
        throw error.friendly()
    }
}

extension BindingsContact {

    /// Scans the contact instance for a specified fact
    ///
    /// - Parameters:
    ///   - fact: enum defined in ```FactType```
    ///           that specifies the type we're
    ///           searching
    ///
    /// - Note: Since GoLang does not support collections
    ///         We need to do this workaround *length* and
    ///         *get* instead of subscripting as in Swift.
    ///
    /// - Returns: Optional string in case we find the the fact
    ///
    /// - ToDo: Return a struct that contains all possible facts (?)
    ///
    func retrieve(fact: FactType) -> String? {
        log(type: .crumbs)

        guard let factList = getFactList() else { return nil }
        for index in 0..<factList.num() {
            if let actualFact = factList.get(index) {
                if actualFact.type() == fact.rawValue {
                    return String(actualFact.stringify().dropFirst())
                }
            }
        }
        return nil
    }
}

extension BindingsSendReport: E2ESendReportType {
    public var marshalled: Data { try! marshal() }
    public var timestamp: Int64 { getTimestampNano() }
    public var uniqueId: Data? { getMessageID() }
    public var roundURL: String { getRoundURL() }
}


public protocol DummyTrafficManaging {
    var status: Bool { get }
    func setStatus(status: Bool)
}

extension BindingsDummyTraffic: DummyTrafficManaging {
    public var status: Bool {
        getStatus()
    }

    public func setStatus(status: Bool) {
        try? setStatus(status)
    }
}
