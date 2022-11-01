import UIKit
import Models
import Shared
import Combine
import Countries
import DependencyInjection

public struct OnboardingSuccessModel {
    var title: String
    var subtitle: String?
    var nextController: (UIViewController) -> Void
}

public final class OnboardingSuccessController: UIViewController {
    @Dependency private var coordinator: OnboardingCoordinating

    lazy private var screenView = OnboardingSuccessView()
    private var cancellables = Set<AnyCancellable>()

    private var model: OnboardingSuccessModel

    public override func loadView() {
        view = screenView
    }

    public init(_ model: OnboardingSuccessModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

        screenView.setTitle(model.title)
        screenView.setSubtitle(model.subtitle)

        screenView.nextButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in model.nextController(self) }
            .store(in: &cancellables)
    }
}
