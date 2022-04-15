import Bindings

final class TextListener: NSObject, BindingsListenerProtocol {
    let callback: (BindingsMessage?) -> ()

    init(_ callback: @escaping (BindingsMessage?) -> Void) {
        self.callback = callback
        super.init()
    }

    func hear(_ message: BindingsMessage?) {
        callback(message)
    }

    func name() -> String { "TEXT_LISTENER" }
}

final class ConfirmationCallback: NSObject, BindingsAuthConfirmCallbackProtocol {
    let callback: (_ partner: BindingsContact) -> ()

    init(_ callback: @escaping (_ partner: BindingsContact) -> ()) {
        self.callback = callback
        super.init()
    }

    func callback(_ partner: BindingsContact?) {
        guard let partner = partner else { return }
        callback(partner)
    }
}

final class RequestCallback: NSObject, BindingsAuthRequestCallbackProtocol {
    let callback: (_ requestor: BindingsContact) -> ()

    init(_ callback: @escaping (_ requestor: BindingsContact) -> ()) {
        self.callback = callback
        super.init()
    }

    func callback(_ requestor: BindingsContact?) {
        guard let requestor = requestor else { return }
        callback(requestor)
    }
}

final class HealthCallback: NSObject, BindingsNetworkHealthCallbackProtocol {
    let callback: (Bool) -> Void

    init(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        super.init()
    }

    func callback(_ p0: Bool) {
        callback(p0)
    }
}

final class LogCallback: NSObject, BindingsLogWriterProtocol {
    let callback: (String?) -> Void

    init(_ callback: @escaping (String?) -> Void) {
        self.callback = callback
        super.init()
    }

    func log(_ p0: String?) {
        callback(p0)
    }
}

final class DeliveryCallback: NSObject, BindingsMessageDeliveryCallbackProtocol {
    let callback: (DeliveryResult) -> Void

    init(_ callback: @escaping (DeliveryResult) -> Void) {
        self.callback = callback
        super.init()
    }

    func eventCallback(_ msgID: Data?, delivered: Bool, timedOut: Bool, roundResults: Data?) {

        let content =
        """
        "Delivery Callback:
        - Timed out: \(timedOut)
        - Delivered: \(delivered)
        - Message ID in base64: \(String(describing: msgID?.base64EncodedString()))
        - Round results in base64: \(String(describing: roundResults?.base64EncodedString()))"
        """

        log(string: content, type: .info)
        callback((msgID, delivered, timedOut, roundResults))
    }
}

final class RoundCallback: NSObject, BindingsRoundCompletionCallbackProtocol {
    let callback: (Bool) -> Void

    init(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        super.init()
    }

    func eventCallback(_ rid: Int, success: Bool, timedOut: Bool) {
        log(string: ">>> Add/Confirm RoundCallback:\nid: \(rid)\nSuccessfull: \(success)\nTimed out: \(timedOut)", type: .info)
        callback(success && !timedOut)
    }
}

final class SearchCallback: NSObject, BindingsSingleSearchCallbackProtocol {
    let callback: (Result<BindingsContact, Error>) -> Void

    init(_ callback: @escaping (Result<BindingsContact, Error>) -> Void) {
        self.callback = callback
        super.init()
    }

    func callback(_ contact: BindingsContact?, error: String?) {
        if let error = error, error.count > 0 {
            callback(.failure(NSError.create(error).friendly()))
            return
        }

        if let contact = contact {
            callback(.success(contact))
        }
    }
}

final class EventCallback: NSObject, BindingsEventCallbackFunctionObjectProtocol {
    let callback: (BackendEvent) -> Void

    init(_ callback: @escaping (BackendEvent) -> Void) {
        self.callback = callback
        super.init()
    }

    func reportEvent(_ priority: Int, category: String?, evtType: String?, details: String?) {
        callback((priority, category, evtType, details))
    }
}

final class GroupRequestCallback: NSObject, BindingsGroupRequestFuncProtocol {
    let callback: (BindingsGroup) -> Void

    init(_ callback: @escaping (BindingsGroup) -> Void) {
        self.callback = callback
        super.init()
    }

    func groupRequestCallback(_ g: BindingsGroup?) {
        guard let group = g else { return }
        callback(group)
    }
}

final class GroupMessageCallback: NSObject, BindingsGroupReceiveFuncProtocol {
    let callback: (BindingsGroupMessageReceive) -> Void

    init(_ callback: @escaping (BindingsGroupMessageReceive) -> Void) {
        self.callback = callback
        super.init()
    }

    func groupReceiveCallback(_ msg: BindingsGroupMessageReceive?) {
        guard let message = msg else { return }
        callback(message)
    }
}

final class MultiLookupCallback: NSObject, BindingsMultiLookupCallbackProtocol {
    let thisCallback: (BindingsContactList?, BindingsIdList?, String?) -> Void

    init(_ callback: @escaping (BindingsContactList?, BindingsIdList?, String?) -> Void) {
        self.thisCallback = callback
        super.init()
    }

    func callback(_ Succeeded: BindingsContactList?, failed: BindingsIdList?, errors: String?) {
        thisCallback(Succeeded, failed, errors)
    }
}

final class PreImageCallback: NSObject, BindingsPreimageNotificationProtocol {
    let callback: (Data?, Bool) -> Void

    init(_ callback: @escaping (Data?, Bool) -> Void) {
        self.callback = callback
        super.init()
    }

    func notify(_ identity: Data?, deleted: Bool) {
        callback(identity, deleted)
    }
}

final class LookupCallback: NSObject, BindingsLookupCallbackProtocol {
    let callback: (Result<BindingsContact, Error>) -> Void

    init(_ callback: @escaping (Result<BindingsContact, Error>) -> Void) {
        self.callback = callback
        super.init()
    }

    func callback(_ contact: BindingsContact?, error: String?) {
        if let error = error, !error.isEmpty {
            callback(.failure(NSError.create(error).friendly()))
            return
        }

        if let contact = contact {
            callback(.success(contact))
        }
    }
}

final class IncomingTransferCallback: NSObject, BindingsFileTransferReceiveFuncProtocol {
    let callback: (Data?, String?, String?, Data?, Int, Data?) -> Void

    init(_ callback: @escaping (Data?, String?, String?, Data?, Int, Data?) -> Void) {
        self.callback = callback
        super.init()
    }

    func receiveCallback(_ tid: Data?, fileName: String?, fileType: String?, sender: Data?, size: Int, preview: Data?) {
        callback(tid, fileName, fileType, sender, size, preview)
    }
}

final class IncomingTransferProgressCallback: NSObject, BindingsFileTransferReceivedProgressFuncProtocol {
    let callback: (Bool, Int, Int, Error?) -> Void

    init(_ callback: @escaping (Bool, Int, Int, Error?) -> Void) {
        self.callback = callback
        super.init()
    }

    func receivedProgressCallback(_ completed: Bool, received: Int, total: Int, t: BindingsFilePartTracker?, err: Error?) {
        callback(completed, received, total, err)
    }
}

final class OutgoingTransferProgressCallback: NSObject, BindingsFileTransferSentProgressFuncProtocol {
    let callback: (Bool, Int, Int, Int, Error?) -> Void

    init(_ callback: @escaping (Bool, Int, Int, Int, Error?) -> Void) {
        self.callback = callback
        super.init()
    }

    func sentProgressCallback(_ completed: Bool, sent: Int, arrived: Int, total: Int, t: BindingsFilePartTracker?, err: Error?) {
        callback(completed, sent, arrived, total, err)
    }
}

final class UpdateBackupCallback: NSObject, BindingsUpdateBackupFuncProtocol {
    let callback: (Data) -> Void

    init(_ callback: @escaping (Data) -> Void) {
        self.callback = callback
        super.init()
    }

    func updateBackup(_ encryptedBackup: Data?) {
        guard let data = encryptedBackup else { return }
        callback(data)
    }
}

final class ResetCallback: NSObject, BindingsAuthResetNotificationCallbackProtocol {
    let callback: (BindingsContact) -> Void

    init(_ callback: @escaping (BindingsContact) -> Void) {
        self.callback = callback
        super.init()
    }

    func callback(_ requestor: BindingsContact?) {
        guard let requestor = requestor else { return }
        callback(requestor)
    }
}

final class RestoreContactsCallback: NSObject, BindingsRestoreContactsUpdaterProtocol {
    let callback: (Int, Int, Int, String?) -> Void

    init(_ callback: @escaping (Int, Int, Int, String?) -> Void) {
        self.callback = callback
        super.init()
    }

    func restoreContactsCallback(_ numFound: Int, numRestored: Int, total: Int, err: String?) {
        callback(numFound, numRestored, total, err)
    }
}
