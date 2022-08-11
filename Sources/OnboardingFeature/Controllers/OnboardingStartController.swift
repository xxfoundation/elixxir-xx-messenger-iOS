import HUD
import UIKit
import Theme
import Shared
import Combine
import DependencyInjection

public final class OnboardingStartController: UIViewController {
    @Dependency private var hud: HUD
    @Dependency private var coordinator: OnboardingCoordinating

    lazy private var screenView = OnboardingStartView()

    private let ndf: String
    private var cancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
    }

    public init(_ ndf: String) {
        self.ndf = ndf
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.customize(translucent: true)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 122/255, green: 235/255, blue: 239/255, alpha: 1).cgColor,
            UIColor(red: 56/255, green: 204/255, blue: 232/255, alpha: 1).cgColor,
            UIColor(red: 63/255, green: 186/255, blue: 253/255, alpha: 1).cgColor,
            UIColor(red: 98/255, green: 163/255, blue: 255/255, alpha: 1).cgColor
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        gradient.frame = screenView.bounds
        screenView.layer.insertSublayer(gradient, at: 0)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        screenView.startButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in coordinator.toTerms(ndf: ndf, from: self) }
            .store(in: &cancellables)
    }
}
