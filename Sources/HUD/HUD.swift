import UIKit
import Theme
import Shared
import Combine
import SnapKit

private enum Constants {
    static let title = Localized.Hud.Error.title
    static let action = Localized.Hud.Error.action
}

public enum HUDStatus: Equatable {
    case on
    case none
    case error(HUDError)

    var isPresented: Bool {
        switch self {
        case .none:
            return false
        case .on, .error:
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

public protocol HUDType {
    func update(with status: HUDStatus)
}

public final class HUD: HUDType {
    // MARK: UI

    private(set) var window: UIWindow?
    private(set) var errorView: ErrorView?
    private(set) var animation: DotAnimation?

    // MARK: Properties

    private var cancellables = Set<AnyCancellable>()

    private var status: HUDStatus = .none {
        didSet {
            if oldValue.isPresented == true && status.isPresented == true {
                self.errorView = nil
                self.animation = nil
                self.window = nil

                switch status {
                case .on:
                    animation = DotAnimation()
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

    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public func update(with status: HUDStatus) {
        self.status = status
    }

    // MARK: Private

    private func showWindow() {
        window = Window()
        window?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        window?.rootViewController = StatusBarViewController(nil)

        if let animation = animation {
            window?.addSubview(animation)
            animation.setColor(.white)
            animation.snp.makeConstraints { $0.center.equalToSuperview() }
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
            self.window = nil
        }
    }
}
