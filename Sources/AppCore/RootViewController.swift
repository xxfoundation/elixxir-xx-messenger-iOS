import Combine
import Dependencies
import HUDFeature
import UIKit

public final class RootViewController: UIViewController {
  @Dependency(\.app.statusBar) var statusBar
  @Dependency(\.app.toastManager) var toastManager

  var cancellables = Set<AnyCancellable>()
  public let navController: UINavigationController
  let hudPresenter = HUDPresenter()

  var toastTimer: Timer?
  let toastTopPadding: CGFloat = 10
  var topToastConstraint: NSLayoutConstraint?

  public init(_ content: UINavigationController) {
    self.navController = content
    super.init(nibName: nil, bundle: nil)
    hudPresenter.parentController = self
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
