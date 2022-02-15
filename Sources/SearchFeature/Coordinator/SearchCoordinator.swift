import UIKit
import Models
import Countries
import Presentation
import ContactFeature

public protocol SearchCoordinating {
    func toContact(_: Contact, from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toCountries(from: UIViewController, _ onChoose: @escaping (Country) -> Void)
}

public struct SearchCoordinator {
    public init() {}

    // MARK: Presenters

    var pusher: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    // MARK: Factories

    var contactFactory: (Contact) -> UIViewController
        = ContactController.init(_:)

    var countriesFactory: (@escaping (Country) -> Void) -> UIViewController
        = CountryListController.init(_:)
}

extension SearchCoordinator: SearchCoordinating {
    public func toContact(
        _ contact: Contact,
        from parent: UIViewController
    ) {
        let screen = contactFactory(contact)
        pusher.present(screen, from: parent)
    }

    public func toCountries(
        from parent: UIViewController,
        _ onChoose: @escaping (Country) -> Void
    ) {
        let screen = countriesFactory(onChoose)
        pusher.present(screen, from: parent)
    }

    public func toPopup(
        _ popup: UIViewController,
        from parent: UIViewController
    ) {
        bottomPresenter.present(popup, from: parent)
    }
}
