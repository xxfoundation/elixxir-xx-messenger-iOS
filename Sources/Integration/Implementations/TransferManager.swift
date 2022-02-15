import Models
import Bindings
import Foundation

extension BindingsFileTransfer: TransferManagerInterface {

    public func endTransferUpload(
        with TID: Data
    ) throws {
        try closeSend(TID)
    }

    public func listenUploadFromTransfer(
        with id: Data,
        _ callback: @escaping (Bool, Int, Int, Int, Error?) -> Void
    ) throws {
        let cb = OutgoingTransferProgressCallback { completed, sent, arrived, total, error in
            callback(completed, sent, arrived, total, error)
        }

        try registerSendProgressCallback(id, progressFunc: cb, periodMS: 1000)
    }

    public func listenDownloadFromTransfer(
        with id: Data,
        _ callback: @escaping (Bool, Int, Int, Error?) -> Void
    ) throws {
        let cb = IncomingTransferProgressCallback { completed, received, total, error in
            callback(completed, received, total, error)
        }

        try registerReceiveProgressCallback(id, progressFunc: cb, periodMS: 1000)
    }

    public func downloadFileFromTransfer(
        with id: Data
    ) throws -> Data {
        try receive(id)
    }

    public func uploadFile(
        _ file: Attachment,
        to recipient: Data,
        _ callback: @escaping (Bool, Int, Int, Int, Error?) -> Void
    ) throws -> Data {
        let cb = OutgoingTransferProgressCallback { completed, sent, arrived, total, error in
            callback(completed, sent, arrived, total, error)
        }

        return try send(
            file.name,
            fileType: file._extension.written,
            fileData: file.data!,
            recipientID: recipient,
            retry: 1,
            preview: nil,
            progressFunc: cb,
            periodMS: 1000
        )
    }
}
