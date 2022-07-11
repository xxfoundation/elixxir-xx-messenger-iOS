import UIKit

final class SearchQRController: UIViewController {
    lazy private var screenView = SearchQRView()

    override func loadView() {
        view = screenView
    }
}
