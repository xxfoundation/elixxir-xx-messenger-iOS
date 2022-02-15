import Models
import Foundation

final class TransferManagerMock: TransferManagerInterface {
    func endTransferUpload(
        with TID: Data
    ) throws {}

    func listenDownloadFromTransfer(
        with: Data,
        _: @escaping (Bool, Int, Int, Error?) -> Void
    ) throws {
        fatalError()
    }

    func listenUploadFromTransfer(
        with: Data,
        _: @escaping (Bool, Int, Int, Int, Error?) -> Void
    ) throws {}

    func downloadFileFromTransfer(
        with: Data
    ) throws -> Data {
        fatalError()
    }

    func uploadFile(
        _: Attachment,
        to: Data,
        _: @escaping (Bool, Int, Int, Int, Error?) -> Void
    ) throws -> Data {
        Data()
    }
}
