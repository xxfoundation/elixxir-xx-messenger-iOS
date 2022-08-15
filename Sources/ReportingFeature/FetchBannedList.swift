import Foundation
import XCTestDynamicOverlay

public struct FetchBannedList {
    public enum Error: Swift.Error, Equatable {
        case network(URLError)
        case invalidResponse
    }

    public typealias Completion = (Result<Data, Error>) -> Void

    public var run: (@escaping Completion) -> Void

    public func callAsFunction(completion: @escaping Completion) {
        run(completion)
    }
}

extension FetchBannedList {
    public static let live = FetchBannedList { completion in
        let url = URL(string: "https://elixxir-bins.s3.us-west-1.amazonaws.com/client/bannedUsers/bannedTesting.csv")!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.network(error as! URLError)))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode),
                  let data = data
            else {
                completion(.failure(.invalidResponse))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}

extension FetchBannedList {
    public static let unimplemented = FetchBannedList(
        run: XCTUnimplemented("\(Self.self)")
    )
}
