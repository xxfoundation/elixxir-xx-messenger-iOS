//import Foundation
//
//public struct Attachment: Codable, Equatable, Hashable {
//
//    public enum Extension: Int64, Codable, CaseIterable {
//        case image
//        case audio
//
//        public static func from(_ string: String) -> Extension? {
//            self.allCases.first{ $0.written == string }
//        }
//
//        public var written: String {
//            switch self {
//            case .image:
//                return "jpeg"
//            case .audio:
//                return "m4a"
//            }
//        }
//
//        public var writtenExtended: String {
//            switch self {
//            case .image:
//                return "image"
//            case .audio:
//                return "voice message"
//            }
//        }
//    }
//
//    public let data: Data?
//    public let name: String
//    public var transferId: Data?
//    public let _extension: Extension
//    public var progress: Float = 0.0
//
//    public init(
//        name: String,
//        data: Data? = nil,
//        transferId: Data? = nil,
//        _extension: Extension
//    ) {
//        self.data = data
//        self.name = name
//        self._extension = _extension
//        self.transferId = transferId
//    }
//}
