import UIKit
import Theme
import Models
import Shared
import Combine
import Countries
import DependencyInjection

final class OnboardingSuccessController: UIViewController {
    @Dependency private var coordinator: OnboardingCoordinating

    lazy private var screenView = OnboardingSuccessView()

    private let isEmail: Bool
    private var cancellables = Set<AnyCancellable>()

    override func loadView() {
        view = screenView
    }

    init(_ isEmail: Bool) {
        self.isEmail = isEmail
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.customize(translucent: true)
    }

    override func viewDidLayoutSubviews() {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        let type = isEmail ?
            Localized.Onboarding.Email.input :
            Localized.Onboarding.Phone.input

        screenView.set(type: type.components(separatedBy: " ").first!)

        screenView.nextButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                if isEmail {
                    coordinator.toPhone(from: self)
                } else {
                    coordinator.toChats(from: self)
                }
            }.store(in: &cancellables)
    }
}
