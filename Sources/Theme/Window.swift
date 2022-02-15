import UIKit
import Combine
import DependencyInjection

public final class Window: UIWindow {
    // MARK: Injected

    @Dependency private var themeController: ThemeControlling

    // MARK: Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifecycle

    public init() {
        super.init(frame: UIScreen.main.bounds)

        themeController.theme
            .sink { [unowned self] in
                overrideUserInterfaceStyle = $0.userInterfaceStyle
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) { nil }
}
