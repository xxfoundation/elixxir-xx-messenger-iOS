import UIKit
import Combine
import DependencyInjection

public final class RootViewController: UIViewController {
  @Dependency var barStylist: StatusBarStylist
  @Dependency var hudDispatcher: HUDController
  @Dependency var toastDispatcher: ToastController

  let content: UIViewController?
  var cancellables = Set<AnyCancellable>()

  var toastTimer: Timer?
  let toastTopPadding: CGFloat = 10
  var topToastConstraint: NSLayoutConstraint?

  public init(_ content: UIViewController?) {
    self.content = content
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override var preferredStatusBarStyle: UIStatusBarStyle  {
    barStylist.styleSubject.value
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    if let content {
      addChild(content)
      view.addSubview(content.view)
      content.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      content.view.frame = view.bounds
      content.didMove(toParent: self)
    } else {
      view.isUserInteractionEnabled = false
    }

    barStylist
      .styleSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        UIView.animate(withDuration: 0.2) {
          self?.setNeedsStatusBarAppearanceUpdate()
        }
      }.store(in: &cancellables)

    toastDispatcher
      .currentToast
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] model in
        let toastView = ToastView(model: model)
        add(toastView: toastView)
        present(toastView: toastView)
      }.store(in: &cancellables)

    hudDispatcher
      .modelPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] model in
        guard model != nil else {
          // REMOVE FROM SUPERVIEW
          return
        }
        // ADD TO SUPERVIEW
      }.store(in: &cancellables)
  }
}

// MARK: - Toaster

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
      self.toastDispatcher.dismissCurrentToast()
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
        guard let self = self else { return }
        self.dismiss(toastView: toastView)
      }
    }
  }
}

// MARK: - HUD

extension RootViewController {
  //  private func showWindow() {
  //    if let animation = animation {
  //      window?.addSubview(animation)
  //      animation.setColor(.white)
  //      animation.snp.makeConstraints { $0.center.equalToSuperview() }
  //    }
  //
  //    if let titleLabel = titleLabel {
  //      window?.addSubview(titleLabel)
  //      titleLabel.textAlignment = .center
  //      titleLabel.numberOfLines = 0
  //      titleLabel.snp.makeConstraints { make in
  //        make.left.equalToSuperview().offset(18)
  //        make.center.equalToSuperview().offset(50)
  //        make.right.equalToSuperview().offset(-18)
  //      }
  //    }
  //
  //    if let actionButton = actionButton {
  //      window?.addSubview(actionButton)
  //      actionButton.snp.makeConstraints {
  //        $0.left.equalToSuperview().offset(18)
  //        $0.right.equalToSuperview().offset(-18)
  //        $0.bottom.equalToSuperview().offset(-50)
  //      }
  //    }
  //
  //    if let errorView = errorView {
  //      window?.addSubview(errorView)
  //      errorView.snp.makeConstraints { make in
  //        make.left.equalToSuperview().offset(18)
  //        make.center.equalToSuperview()
  //        make.right.equalToSuperview().offset(-18)
  //      }
  //
  //      errorView.button
  //        .publisher(for: .touchUpInside)
  //        .receive(on: DispatchQueue.main)
  //        .sink { [unowned self] in hideWindow() }
  //        .store(in: &cancellables)
  //    }
  //
  //    window?.alpha = 0.0
  //    window?.makeKeyAndVisible()
  //
  //    UIView.animate(withDuration: 0.3) { self.window?.alpha = 1.0 }
  //  }
  //
  //  private func hideWindow() {
  //    UIView.animate(withDuration: 0.3) {
  //      self.window?.alpha = 0.0
  //    } completion: { _ in
  //      self.cancellables.removeAll()
  //      self.errorView = nil
  //      self.animation = nil
  //      self.actionButton = nil
  //      self.titleLabel = nil
  //      self.window = nil
  //    }
  //  }


  //    if statusSubject.value.isPresented == true && status.isPresented == true {
  //      self.errorView = nil
  //      self.animation = nil
  //      self.window = nil
  //      self.actionButton = nil
  //      self.titleLabel = nil
  //
  //      switch status {
  //      case .on:
  //        animation = DotAnimation()
  //
  //      case .onTitle(let text):
  //        animation = DotAnimation()
  //        titleLabel = UILabel()
  //        titleLabel!.text = text
  //
  //      case .onAction(let title):
  //        animation = DotAnimation()
  //        actionButton = CapsuleButton()
  //        actionButton!.set(style: .seeThroughWhite, title: title)
  //
  //      case .error(let error):
  //        errorView = ErrorView(with: error)
  //      case .none:
  //        break
  //      }
  //
  //      showWindow()
  //    }

  //    if statusSubject.value.isPresented == false && status.isPresented == true {
  //        switch status {
  //        case .on:
  //          animation = DotAnimation()
  //
  //        case .onTitle(let text):
  //          animation = DotAnimation()
  //          titleLabel = UILabel()
  //          titleLabel!.text = text
  //
  //        case .onAction(let title):
  //          animation = DotAnimation()
  //          actionButton = CapsuleButton()
  //          actionButton!.set(style: .seeThroughWhite, title: title)
  //
  //        case .error(let error):
  //          errorView = ErrorView(with: error)
  //        case .none:
  //          break
  //        }
  //
  //        showWindow()
  //    }

  //    if statusSubject.value.isPresented == true && status.isPresented == false {
  //        hideWindow()
  //    }
}
