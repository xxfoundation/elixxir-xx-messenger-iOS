import Foundation

struct PlistSecrets {
  struct GooglePlist: Decodable {
    let apiKey: String
    let clientId: String

    enum CodingKeys: String, CodingKey {
      case apiKey = "API_KEY"
      case clientId = "CLIENT_ID"
    }
  }

  struct InfoPlist: Decodable {
    let dropboxAppKey: String

    enum CodingKeys: String, CodingKey {
      case dropboxAppKey = "DROPBOX_APP_KEY"
    }
  }

  static var googleAPIKey: String {
    guard let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist"),
          let data = try? Data(contentsOf: url),
          let plist = try? PropertyListDecoder().decode(GooglePlist.self, from: data) else {
      fatalError("Can't decode GoogleService-Info.plist")
    }
    return plist.apiKey
  }

  static var googleClientId: String {
    guard let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist"),
          let data = try? Data(contentsOf: url),
          let plist = try? PropertyListDecoder().decode(GooglePlist.self, from: data) else {
      fatalError("Can't decode GoogleService-Info.plist")
    }
    return plist.clientId
  }

  static var dropboxAppKey: String {
    guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist"),
          let data = try? Data(contentsOf: url),
          let plist = try? PropertyListDecoder().decode(InfoPlist.self, from: data) else {
      fatalError("Can't decode info.plist")
    }
    return plist.dropboxAppKey
  }
}
