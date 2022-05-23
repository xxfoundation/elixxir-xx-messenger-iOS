import UIKit
import Combine
import DependencyInjection

public final class Window: UIWindow {
    @Dependency private var themeController: ThemeControlling

    private var cancellables = Set<AnyCancellable>()

    public init() {
        super.init(frame: UIScreen.main.bounds)

        themeController.theme
            .sink { [unowned self] in overrideUserInterfaceStyle = $0.userInterfaceStyle }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) { nil }
}
