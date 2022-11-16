struct BackendVersionInformation: Codable {
  var info: DappVersionInformation

  private enum CodingKeys: String, CodingKey {
    case info = "dapp-id"
  }
}
