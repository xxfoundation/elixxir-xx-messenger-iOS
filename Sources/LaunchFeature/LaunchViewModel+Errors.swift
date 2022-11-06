import XXClient
import Foundation

extension LaunchViewModel {
  func updateErrors(
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let url = "https://git.xx.network/elixxir/client-error-database/-/raw/main/clientErrors.json"
    downloadErrors(from: url) {
      switch $0 {
      case .success(let string):
        do {
          try UpdateCommonErrors.live(jsonFile: string)
          completion(.success(()))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func downloadErrors(
    from urlString: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, error in
      if let error {
        completion(.failure(error))
        return
      }
      guard let data else {
        fatalError("No errors or data when downloading \(urlString)")
      }
      guard let string = String(data: data, encoding: .utf8) else {
        fatalError("Impossible to decode error json")
      }
      completion(.success(string))
    }.resume()
  }
}
