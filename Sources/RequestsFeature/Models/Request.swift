import XXModels
import Foundation

enum Section: Int {
    case appearing = 0
    case hidden
}

enum Request: Hashable, Equatable {
    case group(Group)
    case contact(Contact)

    var status: RequestStatus {
        switch self {
        case .group:
            return .verified
        case .contact(let contact):
            return contact.authStatus.toRequestStatus()
        }
    }

    var id: Data {
        switch self {
        case .group(let group):
            return group.id
        case .contact(let contact):
            return contact.id
        }
    }
}

enum RequestStatus {
    case verified
    case verifying
    case requested
    case requesting
    case confirming
    case failedToVerify
    case failedToConfirm
    case failedToRequest
}

extension Contact.AuthStatus {
    func toRequestStatus() -> RequestStatus {
        switch self {
        case .friend, .stranger:
            fatalError()
        case .verified:
            return .verified
        case .requested:
            return .requested
        case .verificationInProgress:
            return .verifying
        case .requesting:
            return .requesting
        case .confirming:
            return .confirming
        case .requestFailed:
            return .failedToRequest
        case .verificationFailed:
            return .failedToVerify
        case .confirmationFailed:
            return .failedToConfirm
        case .hidden:
            return .verified
        }
    }
}
