import UIKit
import Combine
import Defaults

public enum Theme: Int {
    case system = 0
    case dark

    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .dark:
            return .dark
        }
    }
}

public protocol ThemeControlling {
    var theme: CurrentValueSubject<Theme, Never> { get }
}

public final class ThemeController: ThemeControlling {
    // MARK: Stored

    @KeyObject(.theme, defaultValue: 0) var storedTheme: Int

    // MARK: Properties

    private var cancellables = Set<AnyCancellable>()
    public let theme = CurrentValueSubject<Theme, Never>(.system)

    // MARK: Lifecycle

    public init() {
        theme.send(Theme(rawValue: storedTheme) ?? .system)

        theme.sink { [unowned self] in storedTheme = $0.rawValue }
            .store(in: &cancellables)
    }
}
