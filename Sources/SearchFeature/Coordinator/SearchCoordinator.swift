import UIKit
import Models
import Countries
import Presentation
import ScrollViewController

public protocol SearchCoordinating {
    func toContact(_: Contact, from: UIViewController)
    func toDrawer(_: UIViewController, from: UIViewController)
    func toNicknameDrawer(_: UIViewController, from: UIViewController)
    func toCountries(from: UIViewController, _: @escaping (Country) -> Void)
}

public struct SearchCoordinator {
    var pushPresenter: Presenting = PushPresenter()
    var bottomPresenter: Presenting = BottomPresenter()
    var fullscreenPresenter: Presenting = FullscreenPresenter()

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

    public func toDrawer(_ drawer: UIViewController, from parent: UIViewController) {
        bottomPresenter.present(drawer, from: parent)
    }

    public func toCountries(from parent: UIViewController, _ onChoose: @escaping (Country) -> Void) {
        let screen = countriesFactory(onChoose)
        pushPresenter.present(screen, from: parent)
    }

    public func toNicknameDrawer(_ target: UIViewController, from parent: UIViewController) {
        let screen = ScrollViewController.embedding(target)
        fullscreenPresenter.present(screen, from: parent)
    }
}

extension ScrollViewController {
    static func embedding(_ viewController: UIViewController) -> ScrollViewController {
        let scrollViewController = ScrollViewController()
        scrollViewController.addChild(viewController)
        scrollViewController.contentView = viewController.view
        scrollViewController.wrapperView.handlesTouchesOutsideContent = false
        scrollViewController.wrapperView.alignContentToBottom = true
        scrollViewController.scrollView.bounces = false

        viewController.didMove(toParent: scrollViewController)
        return scrollViewController
    }
}
