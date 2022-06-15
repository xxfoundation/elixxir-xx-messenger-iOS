//import Foundation
//
//public struct FileTransfer {
//    public enum Request {
//        case withTID(Data)
//        case withContactId(Data)
//    }
//
//    public var tid: Data
//    public var id: Int64?
//    public var contact: Data
//    public var fileName: String
//    public var fileType: String
//    public var isIncoming: Bool
//
//    public static var databaseTableName: String { "transfers" }
//
//    public init(
//        id: Int64? = nil,
//        tid: Data,
//        contact: Data,
//        fileName: String,
//        fileType: String,
//        isIncoming: Bool
//    ) {
//        self.id = id
//        self.tid = tid
//        self.contact = contact
//        self.fileName = fileName
//        self.fileType = fileType
//        self.isIncoming = isIncoming
//    }
//}
//
//extension FileTransfer: Codable {}
//extension FileTransfer: Hashable {}
//extension FileTransfer: Equatable {}
