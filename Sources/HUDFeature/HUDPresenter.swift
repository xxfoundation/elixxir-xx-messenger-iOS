import Combine
import Dependencies
import UIKit
import SwiftUI

public final class HUDPresenter {
  public init() {
    hudManager.observe()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] model in
        if let model = model {
          show(model)
        } else {
          hide()
        }
      }
      .store(in: &cancellables)
  }

  public weak var parentController: UIViewController?

  @Dependency(\.hudManager) var hudManager
  var cancellables = Set<AnyCancellable>()
  var hudController: UIViewController?
  let animationDuration: TimeInterval = 0.2

  func show(_ model: HUDModel) {
    if hudController != nil { hide() }
    guard let parentController else { return }
    let hudController = UIHostingController(rootView: HUDView(model: model))
    hudController.view.alpha = 0
    hudController.view.backgroundColor = .clear
    parentController.addChild(hudController)
    parentController.view.addSubview(hudController.view)
    hudController.view.frame = parentController.view.bounds
    hudController.didMove(toParent: parentController)
    self.hudController = hudController
    UIView.animate(withDuration: animationDuration) {
      hudController.view.alpha = 1
    }
  }

  func hide() {
    guard let hudController else { return }
    hudController.willMove(toParent: nil)
    self.hudController = nil
    UIView.animate(withDuration: animationDuration) {
      hudController.view.alpha = 0
    } completion: { _ in
      hudController.view.removeFromSuperview()
      hudController.removeFromParent()
    }
  }
}
