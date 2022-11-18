import XXClient
import Foundation
import XCTestDynamicOverlay

public struct UpdateErrors {
  public enum Error: Swift.Error {
    case noData
    case decodeFailure
    case network(URLError)
    case bindingsException
  }

  public typealias Completion = (Result<Void, Error>) -> Void

  public var run: (@escaping Completion) -> Void

  public func callAsFunction(_ completion: @escaping Completion) -> Void {
    run(completion)
  }
}

extension UpdateErrors {
  public static let live = UpdateErrors { completion in
    let url = URL(string: "https://git.xx.network/elixxir/client-error-database/-/raw/main/clientErrors.json")
    URLSession.shared.dataTask(with: url!) { data, _, error in
      if let error {
        completion(.failure(.network(error as! URLError)))
        return
      }
      guard let data else {
        completion(.failure(.noData))
        return
      }
      guard let string = String(data: data, encoding: .utf8) else {
        completion(.failure(.decodeFailure))
        return
      }
      do {
        try UpdateCommonErrors.live(jsonFile: string)
        completion(.success(()))
      } catch {
        completion(.failure(.bindingsException))
      }
    }.resume()
  }
}

extension UpdateErrors {
  public static let unimplemented = UpdateErrors(
    run: XCTUnimplemented("\(Self.self)")
  )
}
