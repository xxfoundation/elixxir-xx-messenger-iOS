import Shared
import VersionChecking

extension LaunchViewModel {
  func versionFailed(error: Error) {
    hudController.show(.init(
      title: Localized.Launch.Version.failed,
      content: error.localizedDescription
    ))
  }

  func versionUpdateRequired(_ info: DappVersionInformation) {
    hudController.dismiss()
    routeSubject.send(.update(Update(
      content: info.minimumMessage,
      urlString: info.appUrl,
      positiveActionTitle: Localized.Launch.Version.Required.positive,
      negativeActionTitle: nil,
      actionStyle: .brandColored
    )))
  }

  func versionUpdateRecommended(_ info: DappVersionInformation) {
    hudController.dismiss()
    routeSubject.send(.update(Update(
      content: Localized.Launch.Version.Recommended.title,
      urlString: info.appUrl,
      positiveActionTitle: Localized.Launch.Version.Recommended.positive,
      negativeActionTitle: Localized.Launch.Version.Recommended.negative,
      actionStyle: .simplestColoredRed
    )))
  }
}
