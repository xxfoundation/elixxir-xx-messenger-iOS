import UIKit

final class SearchUsernameController: UIViewController {
    lazy private var screenView = SearchUsernameView()

    override func loadView() {
        view = screenView
    }
}
