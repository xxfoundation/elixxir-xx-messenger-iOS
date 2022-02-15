import Foundation
import DifferenceKit

public struct Contact: Codable, Hashable, Equatable {
    public enum Request {
        case failed
        case friends
        case received
        case requested
        case verificationInProgress
        case withUserId(Data)
        case withUserIds([Data])
        case withUsername(String)
    }

    public enum Status: Int64, Codable {
        case friend
        case stranger
        case verified
        case verificationFailed
        case verificationInProgress
        case requested
        case requesting
        case requestFailed
        case confirming
        case confirmationFailed
    }

    public var id: Int64?
    public var photo: Data?
    public let userId: Data
    public var email: String?
    public var phone: String?
    public var status: Status
    public var marshaled: Data
    public var createdAt: Date
    public let username: String
    public var nickname: String?

    public init(
        photo: Data?,
        userId: Data,
        email: String?,
        phone: String?,
        status: Status,
        marshaled: Data,
        username: String,
        nickname: String?,
        createdAt: Date
    ) {
        self.email = email
        self.phone = phone
        self.photo = photo
        self.status = status
        self.userId = userId
        self.username = username
        self.nickname = nickname
        self.marshaled = marshaled
        self.createdAt = createdAt
    }

    public var differenceIdentifier: Data { userId }

    public static var databaseTableName: String { "contacts" }
}

extension Contact: Differentiable {}
