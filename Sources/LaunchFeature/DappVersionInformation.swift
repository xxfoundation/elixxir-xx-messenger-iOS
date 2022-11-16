public struct DappVersionInformation: Codable {
  public var appUrl: String
  public var minimum: String
  public var isRequired: Bool?
  public var recommended: String
  public var minimumMessage: String

  private enum CodingKeys: String, CodingKey {
    case appUrl = "new_ios_app_url"
    case minimum = "new_ios_min_version"
    case recommended = "new_ios_recommended_version"
    case minimumMessage = "new_minimum_popup_msg"
  }
}
