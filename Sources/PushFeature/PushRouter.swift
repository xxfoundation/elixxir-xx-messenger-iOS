import Foundation

public struct PushRouter {
    public typealias NavigateTo = (Route, @escaping () -> Void) -> Void

    public enum Route {
        case requests
        case groupChat(id: Data)
        case contactChat(id: Data)
    }

    public var navigateTo: NavigateTo

    public init(navigateTo: @escaping NavigateTo) {
        self.navigateTo = navigateTo
    }
}

public extension PushRouter {
    static let noop = PushRouter { _, _ in }
}

