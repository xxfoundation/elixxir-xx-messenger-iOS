import CustomDump
import XCTest
@testable import CollectionView

// MARK: - Example view configurator:

private class ProfileView: UIView {
  let username = UILabel()
}

private struct User {
  var name: String
}

private extension ViewConfigurator where View == ProfileView, Model == User {
  static let profileViewUserConfigurator = ViewConfigurator { view, model in
    view.username.text = model.name
  }
}

// MARK: - Tests:

final class ViewConfiguratorTests: XCTestCase {
  func testExampleConfigurator() {
    let profileView = ProfileView()
    let user = User(name: "John")

    let configure = ViewConfigurator.profileViewUserConfigurator
    configure(profileView, with: user)

    XCTAssertNoDifference(profileView.username.text, user.name)
  }
}
