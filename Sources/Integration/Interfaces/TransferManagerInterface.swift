import Foundation

public protocol TransferManagerInterface {
    func endTransferUpload(
        with TID: Data
    ) throws

    func listenUploadFromTransfer(
        with: Data,
        _: @escaping (Bool, Int, Int, Int, Error?) -> Void
    ) throws

    func listenDownloadFromTransfer(
        with: Data,
        _: @escaping (Bool, Int, Int, Error?) -> Void
    ) throws

    func downloadFileFromTransfer(
        with: Data
    ) throws -> Data

    func uploadFile(
        url: URL,
        to: Data,
        _: @escaping (Bool, Int, Int, Int, Error?) -> Void
    ) throws -> Data
}
