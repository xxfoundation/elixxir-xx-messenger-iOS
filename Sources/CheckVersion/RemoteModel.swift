public struct Remote: Codable {
  var details: RemoteDetails

  private enum CodingKeys: String, CodingKey {
    case details = "dapp-id"
  }
}
