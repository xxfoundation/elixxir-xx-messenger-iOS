import UIKit
import Combine
import DependencyInjection

public protocol StatusBarStyleControlling {
    var style: CurrentValueSubject<UIStatusBarStyle, Never> { get }
}

public struct StatusBarController: StatusBarStyleControlling {
    public init() {}

    public let style = CurrentValueSubject<UIStatusBarStyle, Never>(.lightContent)
}

public final class StatusBarViewController: UIViewController {
    private let content: UIViewController?
    private var cancellables = Set<AnyCancellable>()

    @Dependency private var statusBarController: StatusBarStyleControlling

    public init(_ content: UIViewController?) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override var preferredStatusBarStyle: UIStatusBarStyle  {
        statusBarController.style.value
    }

    public override func loadView() {
        let view = UIView()
        view.backgroundColor = .clear
        self.view = view
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let content = content {
            addChild(content)
            view.addSubview(content.view)
            content.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            content.view.frame = view.bounds
            content.didMove(toParent: self)
        } else {
            view.isUserInteractionEnabled = false
        }

        statusBarController.style
            .receive(on: DispatchQueue.main)
            .sink { [weak self] style in
                UIView.animate(withDuration: 0.2) {
                    self?.setNeedsStatusBarAppearanceUpdate()
                }
            }.store(in: &cancellables)
    }
}
