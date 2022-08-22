import Foundation
import UIKit
import XCTestDynamicOverlay

public struct MakeAppScreenshot {
    public enum Error: Swift.Error, Equatable {
        case unableToGetForegroundWindowScene
        case unableToGetKeyWindow
    }

    public var run: () throws -> UIImage

    public func callAsFunction() throws -> UIImage {
        try run()
    }
}

extension MakeAppScreenshot {
    public static let live = MakeAppScreenshot {
        let scene: UIWindowScene? = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first

        guard let scene = scene else {
            throw Error.unableToGetForegroundWindowScene
        }

        let window: UIWindow? = scene.windows.first(where: \.isKeyWindow)

        guard let keyWindow = window else {
            throw Error.unableToGetKeyWindow
        }

        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = scene.screen.scale

        let renderer = UIGraphicsImageRenderer(
            bounds: keyWindow.bounds,
            format: rendererFormat
        )

        return renderer.image { ctx in
            keyWindow.layer.render(in: ctx.cgContext)
        }
    }
}

extension MakeAppScreenshot {
    public static let unimplemented = MakeAppScreenshot(
        run: XCTUnimplemented("\(Self.self)")
    )
}
