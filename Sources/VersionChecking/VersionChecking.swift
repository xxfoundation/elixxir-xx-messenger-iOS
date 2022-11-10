import Combine
import Foundation

public typealias VersionCompletion = (VersionCheck.Requirement) -> Void

public struct VersionCheck {
  public enum Requirement {
    case upToDate
    case failure(Error)
    case outdated(DappVersionInformation)
  }

  public var verify: (@escaping VersionCompletion) -> Void
}

public extension VersionCheck {
  static let mock: Self = .init { $0(.upToDate) }

  static let live: Self = .init { completion in
    let request = URLRequest(
      url: URL(string: "https://elixxir-bins.s3-us-west-1.amazonaws.com/client/dapps/appdb.json")!,
      cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
      timeoutInterval: 5
    )
    URLSession.shared.dataTask(with: request) { data, _, error in
      if let error {
        completion(.failure(error))
        return
      }
      guard let data else {
        fatalError("No data for version checking")
      }
      guard var model = try? JSONDecoder().decode(BackendVersionInformation.self, from: data) else {
        fatalError()
      }
      let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
      if bundleVersion >= model.info.recommended {
        completion(.upToDate)
      } else {
        if bundleVersion < model.info.minimum {
          model.info.isRequired = true
        }
        completion(.outdated(model.info))
      }
    }.resume()
  }
}
