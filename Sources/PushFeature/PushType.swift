public enum PushType: String {
    case e2e
    case reset
    case endFT
    case group
    case silent
    case groupRq
    case confirm
    case request
    case `default`

    var unknownSenderContent: String? {
        switch self {
        case .silent, .`default`:
            return nil
        case .endFT:
            return "New media received"
        case .group:
            return "New group message"
        case .groupRq:
            return "Group request received"
        case .e2e:
            return "New private message"
        case .reset:
            return "One of your contacts has restored their account"
        case .request:
            return "Request received"
        case .confirm:
            return "Request accepted"
        }
    }

    var knownSenderContent: (String) -> String? {
        switch self {
        case .silent, .`default`:
            return { _ in nil }
        case .e2e:
            return { String(format: "%@ sent you a private message", $0) }
        case .reset:
            return { String(format: "%@ restored their account", $0) }
        case .endFT:
            return { String(format: "%@ sent you a file", $0) }
        case .group:
            return { String(format: "%@ sent you a group message", $0) }
        case .groupRq:
            return { String(format: "%@ sent you a group request", $0) }
        case .confirm:
            return { String(format: "%@ confirmed your contact request", $0) }
        case .request:
            return { _ in "Request received" }
        }
    }
}
