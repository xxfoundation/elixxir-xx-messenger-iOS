import Foundation
import XCTestDynamicOverlay

public struct FetchRemoteVersion {
  public enum Error: Swift.Error {
    case noData
    case requestError
    case decodeFailure
  }

  public typealias Completion = (Result<Remote, Error>) -> Void

  public var run: (@escaping Completion) -> Void

  public func callAsFunction(_ completion: @escaping Completion) -> Void {
    run(completion)
  }
}

extension FetchRemoteVersion {
  public static let live = FetchRemoteVersion { completion in
    let urlString = "https://elixxir-bins.s3-us-west-1.amazonaws.com/client/dapps/appdb.json"
    let request = URLRequest(
      url: URL(string: urlString)!,
      cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
      timeoutInterval: 5
    )
    URLSession.shared.dataTask(with: request) { data, _, error in
      guard error == nil else {
        completion(.failure(.requestError))
        return
      }
      guard let data else {
        completion(.failure(.noData))
        return
      }
      do {
        let model = try JSONDecoder().decode(Remote.self, from: data)
        completion(.success(model))
      } catch {
        completion(.failure(.decodeFailure))
      }
    }.resume()
  }
}

extension FetchRemoteVersion {
  public static let unimplemented = FetchRemoteVersion(
    run: XCTUnimplemented("\(Self.self)")
  )
}
