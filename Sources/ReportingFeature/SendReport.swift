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

    public static func mock(
        result: Result<Void, Error> = .success(())
    ) -> SendReport {
        SendReport { report, completion in
            print("[SendReport.mock] Sending report: \(report)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                print("[SendReport.mock] Sending report finished")
                completion(result)
            }
        }
    }
}

extension SendReport {
    public static let unimplemented = SendReport(
        run: XCTUnimplemented("\(Self.self)")
    )
}

private final class SessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let authMethod = challenge.protectionSpace.authenticationMethod
        guard authMethod == NSURLAuthenticationMethodServerTrust else {
            return completionHandler(.cancelAuthenticationChallenge, nil)
        }

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(.cancelAuthenticationChallenge, nil)
        }

        guard let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return completionHandler(.cancelAuthenticationChallenge, nil)
        }

        let serverCertCFData = SecCertificateCopyData(serverCert)
        let serverCertData = Data(
            bytes: CFDataGetBytePtr(serverCertCFData),
            count: CFDataGetLength(serverCertCFData)
        )

        let localCertURL = Bundle.module.url(forResource: "report_cert", withExtension: "der")!
        let localCertData = try! Data(contentsOf: localCertURL)

        guard serverCertData == localCertData else {
            return completionHandler(.cancelAuthenticationChallenge, nil)
        }

        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
