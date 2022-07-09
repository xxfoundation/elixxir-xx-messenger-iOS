import UIKit

final class SearchEmailController: UIViewController {
    lazy private var screenView = SearchEmailView()

    override func loadView() {
        view = screenView
    }
}
