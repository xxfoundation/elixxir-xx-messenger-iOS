import UIKit
import Shared
import Combine
import SnapKit

private enum Constants {
  static let title = Localized.Hud.Error.title
  static let action = Localized.Hud.Error.action
}

public enum HUDStatus: Equatable {
  case none
  case on
  case onTitle(String)
  case onAction(String)
  case error(HUDError)

  var isPresented: Bool {
    switch self {
    case .none:
      return false
    case .on, .error, .onTitle, .onAction:
      return true
    }
  }
}

public struct HUDError: Equatable {
  var title: String
  var content: String
  var buttonTitle: String
  var dismissable: Bool

  public init(
    content: String,
    title: String? = nil,
    buttonTitle: String? = nil,
    dismissable: Bool = true
  ) {
    self.content = content
    self.title = title ?? Constants.title
    self.buttonTitle = buttonTitle ?? Constants.action
    self.dismissable = dismissable
  }

  public init(with error: Error) {
    self.title = Constants.title
    self.buttonTitle = Constants.action
    self.content = error.localizedDescription
    self.dismissable = true
  }
}

public final class HUD {
  private(set) var window: UIWindow?
  private(set) var errorView: ErrorView?
  private(set) var titleLabel: UILabel?
  private(set) var animation: DotAnimation?
  public var actionButton: CapsuleButton?
  private var cancellables = Set<AnyCancellable>()

  private var status: HUDStatus = .none {
    didSet {
      if oldValue.isPresented == true && status.isPresented == true {
        self.errorView = nil
        self.animation = nil
        self.window = nil
        self.actionButton = nil
        self.titleLabel = nil

        switch status {
        case .on:
          animation = DotAnimation()

        case .onTitle(let text):
          animation = DotAnimation()
          titleLabel = UILabel()
          titleLabel!.text = text

        case .onAction(let title):
          animation = DotAnimation()
          actionButton = CapsuleButton()
          actionButton!.set(style: .seeThroughWhite, title: title)

        case .error(let error):
          errorView = ErrorView(with: error)
        case .none:
          break
        }

        showWindow()
      }

      if oldValue.isPresented == false && status.isPresented == true {
        switch status {
        case .on:
          animation = DotAnimation()

        case .onTitle(let text):
          animation = DotAnimation()
          titleLabel = UILabel()
          titleLabel!.text = text

        case .onAction(let title):
          animation = DotAnimation()
          actionButton = CapsuleButton()
          actionButton!.set(style: .seeThroughWhite, title: title)

        case .error(let error):
          errorView = ErrorView(with: error)
        case .none:
          break
        }

        showWindow()
      }

      if oldValue.isPresented == true && status.isPresented == false {
        hideWindow()
      }
    }
  }

  public init() {}

  public func update(with status: HUDStatus) {
    self.status = status
  }

  private func showWindow() {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    window?.rootViewController = RootViewController(nil)

    if let animation = animation {
      window?.addSubview(animation)
      animation.setColor(.white)
      animation.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    if let titleLabel = titleLabel {
      window?.addSubview(titleLabel)
      titleLabel.textAlignment = .center
      titleLabel.numberOfLines = 0
      titleLabel.snp.makeConstraints { make in
        make.left.equalToSuperview().offset(18)
        make.center.equalToSuperview().offset(50)
        make.right.equalToSuperview().offset(-18)
      }
    }

    if let actionButton = actionButton {
      window?.addSubview(actionButton)
      actionButton.snp.makeConstraints {
        $0.left.equalToSuperview().offset(18)
        $0.right.equalToSuperview().offset(-18)
        $0.bottom.equalToSuperview().offset(-50)
      }
    }

    if let errorView = errorView {
      window?.addSubview(errorView)
      errorView.snp.makeConstraints { make in
        make.left.equalToSuperview().offset(18)
        make.center.equalToSuperview()
        make.right.equalToSuperview().offset(-18)
      }

      errorView.button
        .publisher(for: .touchUpInside)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in hideWindow() }
        .store(in: &cancellables)
    }

    window?.alpha = 0.0
    window?.makeKeyAndVisible()

    UIView.animate(withDuration: 0.3) { self.window?.alpha = 1.0 }
  }

  private func hideWindow() {
    UIView.animate(withDuration: 0.3) {
      self.window?.alpha = 0.0
    } completion: { _ in
      self.cancellables.removeAll()
      self.errorView = nil
      self.animation = nil
      self.actionButton = nil
      self.titleLabel = nil
      self.window = nil
    }
  }
}
