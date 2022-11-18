import Foundation
import XCTestDynamicOverlay

public struct CheckVersion {
  public enum VersionState {
    case updated
    case outdated(String)
    case wayTooOld(String, String)
  }

  public enum Error: Swift.Error {
    case noLocalVersion
    case failureFetchingRemote(FetchRemoteVersion.Error)
  }

  public typealias Completion = (Result<VersionState, Error>) -> Void

  public var run: (@escaping Completion) -> Void

  public func callAsFunction(_ completion: @escaping Completion) -> Void {
    run(completion)
  }
}

extension CheckVersion {
  public static func live(
    local: FetchLocalVersion = .live,
    remote: FetchRemoteVersion = .live
  ) -> CheckVersion {
    .init { completion in
      remote {
        switch $0 {
        case .success(let remoteModel):
          guard let localVersion = local() else {
            completion(.failure(.noLocalVersion))
            return
          }
          if localVersion >= remoteModel.details.recommendedVersion {
            completion(.success(.updated))
          } else {
            if localVersion < remoteModel.details.minimumVersion {
              completion(.success(.wayTooOld(
                remoteModel.details.appUrl,
                remoteModel.details.minimumVersionMessage
              )))
              return
            }
            completion(.success(.outdated(remoteModel.details.appUrl)))
          }
        case .failure(let error):
          completion(.failure(.failureFetchingRemote(error)))
        }
      }
    }
  }
}

extension CheckVersion {
  public static let unimplemented = CheckVersion(
    run: XCTUnimplemented("\(Self.self)")
  )
}
