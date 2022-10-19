import UIKit
import Shared
import Presentation
import ScrollViewController

public typealias SFTPDetailsClosure = (String, String, String) -> Void

public protocol BackupCoordinating {
  func toDrawer(
    _: UIViewController,
    from: UIViewController
  )

  func toSFTP(
    from: UIViewController,
    detailsClosure: @escaping SFTPDetailsClosure
  )

  func toPassphrase(
    from: UIViewController,
    cancelClosure: @escaping EmptyClosure,
    passphraseClosure: @escaping StringClosure
  )
}

public struct BackupCoordinator: BackupCoordinating {
  var pushPresenter: Presenting = PushPresenter()
  var fullscreenPresenter: Presenting = FullscreenPresenter()

  var sftpFactory: (@escaping SFTPDetailsClosure) -> UIViewController

  var passphraseFactory: (
    @escaping EmptyClosure,
    @escaping StringClosure
  ) -> UIViewController

  public init(
    sftpFactory: @escaping (
      @escaping SFTPDetailsClosure
    ) -> UIViewController,
    passphraseFactory: @escaping (
      @escaping EmptyClosure,
      @escaping StringClosure
    ) -> UIViewController
  ) {
    self.sftpFactory = sftpFactory
    self.passphraseFactory = passphraseFactory
  }
}

public extension BackupCoordinator {
  func toSFTP(
    from parent: UIViewController,
    detailsClosure: @escaping SFTPDetailsClosure
  ) {
    let screen = sftpFactory(detailsClosure)
    pushPresenter.present(screen, from: parent)
  }

  func toDrawer(
    _ screen: UIViewController,
    from parent: UIViewController
  ) {
    let target = ScrollViewController.embedding(screen)
    fullscreenPresenter.present(target, from: parent)
  }

  func toPassphrase(
    from parent: UIViewController,
    cancelClosure: @escaping EmptyClosure,
    passphraseClosure: @escaping StringClosure
  ) {
    let screen = passphraseFactory(cancelClosure, passphraseClosure)
    let target = ScrollViewController.embedding(screen)
    fullscreenPresenter.present(target, from: parent)
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
