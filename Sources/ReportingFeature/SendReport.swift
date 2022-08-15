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

private final class SessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        if authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust,
           handleServerTrustChallenge(serverTrust) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

private func handleServerTrustChallenge(_ serverTrust: SecTrust) -> Bool {
    guard let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
        return false
    }

    let serverCertCFData = SecCertificateCopyData(serverCert)
    let serverCertNSData = NSData(
        bytes: CFDataGetBytePtr(serverCertCFData),
        length: CFDataGetLength(serverCertCFData)
    )

    let localCertPath = Bundle.module.path(forResource: "report_cert", ofType: "crt")!
    let localCertNSData = NSData(contentsOfFile: localCertPath)!

    return serverCertNSData.isEqual(to: localCertNSData as Data)
}
