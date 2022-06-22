import UIKit
import DifferenceKit

public protocol IndexableItem {
    var indexedOn: NSString { get }
}

public class IndexedListCollator<Item: IndexableItem> {
    private final class CollationWrapper: NSObject {
        let value: Any
        @objc let indexedOn: NSString

        init(value: Any, indexedOn: NSString) {
            self.value = value
            self.indexedOn = indexedOn
        }

        func unwrappedValue<UnwrappedType>() -> UnwrappedType {
            return value as! UnwrappedType
        }
    }

    public init() {}

    public func sectioned(items: [Item]) -> (sections: [[Item]], collation: UILocalizedIndexedCollation) {
        let collation = UILocalizedIndexedCollation.current()
        let selector = #selector(getter: CollationWrapper.indexedOn)

        let wrappedItems = items.map { item in
            CollationWrapper(value: item, indexedOn: item.indexedOn)
        }

        let sortedObjects = collation.sortedArray(from: wrappedItems, collationStringSelector: selector) as! [CollationWrapper]

        var sections = collation.sectionIndexTitles.map { _ in [Item]() }
        sortedObjects.forEach { item in
            let sectionNumber = collation.section(for: item, collationStringSelector: selector)
            sections[sectionNumber].append(item.unwrappedValue())
        }

        return (sections: sections.filter { !$0.isEmpty }, collation: collation)
    }
}
//
//public struct Contact: Codable, Hashable, Equatable {
//    public enum Request {
//        case all
//        case failed
//        case friends
//        case received
//        case requested
//        case isRecent
//        case verificationInProgress
//        case withUserId(Data)
//        case withUserIds([Data])
//        case withUsername(String)
//    }
//
//    public enum Status: Int64, Codable {
//        case friend
//        case stranger
//        case verified
//        case verificationFailed
//        case verificationInProgress
//        case requested
//        case requesting
//        case requestFailed
//        case confirming
//        case confirmationFailed
//        case hidden
//    }
//
//    public var id: Int64?
//    public var photo: Data?
//    public let userId: Data
//    public var email: String?
//    public var phone: String?
//    public var status: Status
//    public var marshaled: Data
//    public var createdAt: Date
//    public let username: String
//    public var nickname: String?
//    public var isRecent: Bool
//
//    public init(
//        photo: Data?,
//        userId: Data,
//        email: String?,
//        phone: String?,
//        status: Status,
//        marshaled: Data,
//        username: String,
//        nickname: String?,
//        createdAt: Date,
//        isRecent: Bool
//    ) {
//        self.email = email
//        self.phone = phone
//        self.photo = photo
//        self.status = status
//        self.userId = userId
//        self.username = username
//        self.nickname = nickname
//        self.marshaled = marshaled
//        self.createdAt = createdAt
//        self.isRecent = isRecent
//    }
//
//    public var differenceIdentifier: Data { userId }
//
//    public static var databaseTableName: String { "contacts" }
//}
//
//extension Contact: Differentiable {}
//extension Contact: IndexableItem {
//    public var indexedOn: NSString {
//        guard let nickname = nickname else {
//            return "\(username.first!)" as NSString
//        }
//
//        return "\(nickname.first!)" as NSString
//    }
//}
