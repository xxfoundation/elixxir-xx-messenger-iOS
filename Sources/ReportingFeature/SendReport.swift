import Foundation
import XCTestDynamicOverlay

public struct SendReport {
    public typealias Completion = (Result<Void, Error>) -> Void

    public var run: (Report, @escaping Completion) -> Void

    public func callAsFunction(_ report: Report, completion: @escaping Completion) {
        run(report, completion)
    }
}

extension SendReport {
    public static let live = SendReport { report, completion in
        let url = URL(string: "https://3.74.237.181:11420/report")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONEncoder().encode(report)
        } catch {
            completion(.failure(error))
            return
        }
        let session = URLSession(
            configuration: .default,
            delegate: SessionDelegate(),
            delegateQueue: nil
        )
        let task = session.dataTask(with: request) { _, _, error in
            defer { session.invalidateAndCancel() }
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
        task.resume()
    }
}

extension SendReport {
    public static let unimplemented = SendReport(
        run: XCTUnimplemented("\(Self.self)")
    )
}

private class SessionDelegate: NSObject, URLSessionDelegate {
    // TODO: handle TLS
}
