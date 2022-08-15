import DrawerFeature
import Shared
import UIKit
import XCTestDynamicOverlay

public struct MakeReportDrawer {
    public struct Config {
        public init(
            onReport: @escaping () -> Void = {},
            onCancel: @escaping () -> Void = {}
        ) {
            self.onReport = onReport
            self.onCancel = onCancel
        }

        public var onReport: () -> Void
        public var onCancel: () -> Void
    }

    public var run: (Config) -> UIViewController

    public func callAsFunction(_ config: Config) -> UIViewController {
        run(config)
    }
}

extension MakeReportDrawer {
    public static let live = MakeReportDrawer { config in
        let cancelButton = CapsuleButton()
        cancelButton.setStyle(.seeThrough)
        cancelButton.setTitle(Localized.Chat.Report.cancel, for: .normal)

        let reportButton = CapsuleButton()
        reportButton.setStyle(.red)
        reportButton.setTitle(Localized.Chat.Report.action, for: .normal)

        let drawer = DrawerController(with: [
            DrawerImage(
                image: Asset.drawerNegative.image
            ),
            DrawerText(
                font: Fonts.Mulish.semiBold.font(size: 18.0),
                text: Localized.Chat.Report.title,
                color: Asset.neutralActive.color
            ),
            DrawerText(
                font: Fonts.Mulish.semiBold.font(size: 14.0),
                text: Localized.Chat.Report.subtitle,
                color: Asset.neutralWeak.color,
                lineHeightMultiple: 1.35,
                spacingAfter: 25
            ),
            DrawerStack(
                axis: .vertical,
                spacing: 20.0,
                views: [reportButton, cancelButton]
            )
        ])

        reportButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned drawer] in
                drawer.dismiss(animated: true) {
                    config.onReport()
                }
            }
            .store(in: &drawer.cancellables)

        cancelButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned drawer] in
                drawer.dismiss(animated: true) {
                    config.onCancel()
                }
            }
            .store(in: &drawer.cancellables)

        return drawer
    }
}

extension MakeReportDrawer {
    public static let unimplemented = MakeReportDrawer(
        run: XCTUnimplemented("\(Self.self)")
    )
}
