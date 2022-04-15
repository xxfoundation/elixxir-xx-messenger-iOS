import UIKit
import Models
import Combine

public typealias RestoreProgress = (Float) -> Void
public typealias RestoreDownloadFinished = (Result<Data, Error>) -> Void

public protocol RestoreServiceType {
    var inProgress: AnyPublisher<Void, Never> { get }

    var settings: AnyPublisher<RestoreSettings, Never> { get }

    func authorize(service: CloudService, from: UIViewController)

    func download(
        from settings: RestoreSettings,
        progress: @escaping RestoreProgress,
        whenFinished: @escaping RestoreDownloadFinished
    )
}
