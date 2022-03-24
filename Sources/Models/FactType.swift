import Foundation

public enum FactType: Int {
    case username = 0
    case email
    case phone
    case nickname

    public var description: String {
        switch self {
        case .email:
            return "Email"
        case .nickname:
            return "Nickname"
        case .phone:
            return "Phone"
        case .username:
            return "Username"
        }
    }

    public var prefix: String {
        switch self {
        case .email:
            return "E"
        case .nickname:
            return "N"
        case .phone:
            return "P"
        case .username:
            return "U"
        }
    }
}
