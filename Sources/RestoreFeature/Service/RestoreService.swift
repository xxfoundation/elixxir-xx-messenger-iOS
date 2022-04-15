//import UIKit
//import Models
//import Combine
//
//import DependencyInjection
//
//public struct RestoreService: RestoreServiceType {
//
//
//
//    @Dependency private var coordinator: RestoreCoordinating
//
//    public var inProgress: AnyPublisher<Void, Never> { inProgressSubject.eraseToAnyPublisher() }
//    public var settings: AnyPublisher<RestoreSettings, Never> { settingsSubject.eraseToAnyPublisher() }
//
//    private let inProgressSubject = PassthroughSubject<Void, Never>()
//    private let settingsSubject = PassthroughSubject<RestoreSettings, Never>()
//
//    private var cancellables = Set<AnyCancellable>()
//
//    public init() {}
//
//    public func authorize(service: CloudService, from controller: UIViewController) {
//        }
//    }
//
//    public func download(
//        from settings: RestoreSettings,
//        progress: @escaping RestoreProgress,
//        whenFinished: @escaping RestoreDownloadFinished
//    ) {
//        drive.downloadBackup(
//            settings.backup!.id,
//            progressCallback: progress,
//            whenFinished
//        )
//    }
//}
