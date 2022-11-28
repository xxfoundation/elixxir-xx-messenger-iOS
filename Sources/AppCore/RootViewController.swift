import UIKit
import Combine
import Dependencies

public final class RootViewController: UIViewController {
  @Dependency(\.app.statusBar) var statusBar
  @Dependency(\.app.hudManager) var hudManager
  @Dependency(\.app.toastManager) var toastManager
  
  var hud: HUDView?
  var cancellables = Set<AnyCancellable>()
  public let navController: UINavigationController
  
  var toastTimer: Timer?
  let toastTopPadding: CGFloat = 10
  var topToastConstraint: NSLayoutConstraint?
  
  public init(_ content: UINavigationController) {
    self.navController = content
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { nil }
  
  public override var preferredStatusBarStyle: UIStatusBarStyle  {
    statusBar.get()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    addChild(navController)
    view.addSubview(navController.view)
    navController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    navController.view.frame = view.bounds
    navController.didMove(toParent: self)
    
    statusBar
      .observe()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        UIView.animate(withDuration: 0.2) {
          self?.setNeedsStatusBarAppearanceUpdate()
        }
      }.store(in: &cancellables)
    
    toastManager
      .observe()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] model in
        let toastView = ToastView(model: model)
        add(toastView: toastView)
        present(toastView: toastView)
      }.store(in: &cancellables)
    
    hudManager
      .observe()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] model in
        guard let model else {
          guard let hud else { return }
          UIView.animate(withDuration: 0.2) {
            hud.alpha = 0.0
          } completion: { _ in
            hud.removeFromSuperview()
            self.hud = nil
          }
          return
        }
        add(hudView: HUDView().setup(model: model))
      }.store(in: &cancellables)
  }
}

extension RootViewController {
  @objc private func didPanToast(_ sender: UIPanGestureRecognizer) {
    guard let toastView = sender.view else { return }
    
    switch sender.state {
    case .began, .changed:
      toastTimer?.invalidate()
      let padding = toastTopPadding + min(0, sender.translation(in: view).y)
      topToastConstraint?.constant = padding
      
    case .cancelled, .ended, .failed:
      let halfFrameHeight = -0.5 * toastView.frame.height
      let verticalTranslation = sender.translation(in: toastView).y
      let didSwipeAboveHalf = verticalTranslation < halfFrameHeight
      
      if didSwipeAboveHalf {
        dismiss(toastView: toastView)
      } else {
        present(toastView: toastView)
      }
      
    case .possible:
      break
    @unknown default:
      break
    }
  }
  
  private func dismiss(toastView: UIView) {
    toastView.isUserInteractionEnabled = false
    topToastConstraint?.constant = -(toastView.frame.height + view.safeAreaLayoutGuide.layoutFrame.minY)
    
    topToastConstraint = nil
    UIView.animate(withDuration: 0.25) {
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    } completion: { _ in
      toastView.isUserInteractionEnabled = true
      toastView.removeFromSuperview()
      self.toastManager.dismiss()
    }
  }
  
  private func add(toastView: UIView) {
    let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanToast(_:)))
    toastView.addGestureRecognizer(gestureRecognizer)
    
    toastView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toastView)
    
    NSLayoutConstraint.activate([
      toastView.heightAnchor.constraint(equalToConstant: 78),
      toastView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
      toastView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20)
    ])
    
    topToastConstraint = toastView.topAnchor.constraint(
      equalTo: view.safeAreaLayoutGuide.topAnchor,
      constant: -(toastView.frame.height + view.safeAreaLayoutGuide.layoutFrame.height)
    )
    
    topToastConstraint?.isActive = true
    
    view.setNeedsLayout()
    view.layoutIfNeeded()
  }
  
  private func present(toastView: UIView) {
    toastView.isUserInteractionEnabled = false
    topToastConstraint?.constant = toastTopPadding
    
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0.5,
      options: .curveEaseInOut
    ) {
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    } completion: { _ in
      toastView.isUserInteractionEnabled = true
      
      self.toastTimer?.invalidate()
      self.toastTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
        guard let self else { return }
        self.dismiss(toastView: toastView)
      }
    }
  }
}

extension RootViewController {
  private func add(hudView: HUDView) {
    if let hud {
      hud.removeFromSuperview()
      self.hud = nil
    }
    
    hudView.alpha = 0.0
    hudView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(hudView)
    
    NSLayoutConstraint.activate([
      hudView.topAnchor.constraint(equalTo: view.topAnchor),
      hudView.leftAnchor.constraint(equalTo: view.leftAnchor),
      hudView.rightAnchor.constraint(equalTo: view.rightAnchor),
      hudView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    view.setNeedsLayout()
    view.layoutIfNeeded()
    
    UIView.animate(withDuration: 0.2) {
      hudView.alpha = 1.0
    }
    
    hud = hudView
  }
}
