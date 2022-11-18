public struct RemoteDetails: Codable {
  public var appUrl: String
  public var minimumVersion: String
  public var recommendedVersion: String
  public var minimumVersionMessage: String

  private enum CodingKeys: String, CodingKey {
    case appUrl = "new_ios_app_url"
    case minimumVersion = "new_ios_min_version"
    case minimumVersionMessage = "new_minimum_popup_msg"
    case recommendedVersion = "new_ios_recommended_version"
  }
}
