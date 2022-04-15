import UIKit
import Models
import Countries
import Presentation

public protocol SearchCoordinating {
    func toContact(_: Contact, from: UIViewController)
    func toPopup(_: UIViewController, from: UIViewController)
    func toCountries(from: UIViewController, _: @escaping (Country) -> Void)
}

public struct SearchCoordinator {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()

    var contactFactory: (Contact) -> UIViewController
    var countriesFactory: (@escaping (Country) -> Void) -> UIViewController

    public init(
        contactFactory: @escaping (Contact) -> UIViewController,
        countriesFactory: @escaping (@escaping (Country) -> Void) -> UIViewController
    ) {
        self.contactFactory = contactFactory
        self.countriesFactory = countriesFactory
    }
}

extension SearchCoordinator: SearchCoordinating {
    public func toContact(_ contact: Contact, from parent: UIViewController) {
        let screen = contactFactory(contact)
        pushPresenter.present(screen, from: parent)
    }

    public func toPopup(_ popup: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(popup, from: parent)
    }

    public func toCountries(from parent: UIViewController, _ onChoose: @escaping (Country) -> Void) {
        let screen = countriesFactory(onChoose)
        pushPresenter.present(screen, from: parent)
    }
}
