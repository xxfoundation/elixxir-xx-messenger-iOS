import UIKit
import Models
import Combine
import Foundation
import GoogleDriveFeature
import DependencyInjection

public struct RestoreServiceMock: RestoreServiceType {
    public var inProgress: AnyPublisher<Void, Never> {
        fatalError()
    }

    public var settings: AnyPublisher<RestoreSettings, Never> {
        fatalError()
    }

    public init() {}

    public func didSelectBackup(at url: URL) {}

    public func authorize(service: CloudService, from: UIViewController) {}

    public func download(
        from settings: RestoreSettings,
        progress: @escaping RestoreProgress,
        whenFinished: @escaping RestoreDownloadFinished
    ) {
        fatalError()
    }
}
