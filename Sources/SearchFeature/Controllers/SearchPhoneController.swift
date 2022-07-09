import UIKit

final class SearchPhoneController: UIViewController {
    lazy private var screenView = SearchPhoneView()

    override func loadView() {
        view = screenView
    }
}
