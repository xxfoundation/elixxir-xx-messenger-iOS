import UIKit
import WebKit
import Shared
import Combine
import Defaults
import AppResources
import AppNavigation
import ComposableArchitecture

public final class TermsConditionsController: UIViewController {
  @Dependency(\.navigator) var navigator

  @KeyObject(.username, defaultValue: nil) var username: String?
  @KeyObject(.acceptedTerms, defaultValue: false) var didAcceptTerms: Bool

  private var cancellables = Set<AnyCancellable>()
  private lazy var screenView = TermsConditionsView()

  public override func loadView() {
    view = screenView
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    navigationController?.navigationBar.customize(
      translucent: true,
      tint: Asset.neutralWhite.color
    )
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
    screenView
      .radioComponent
      .radioButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        screenView.radioComponent.isEnabled.toggle()
        screenView.nextButton.isEnabled = screenView.radioComponent.isEnabled
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
      }.store(in: &cancellables)

    screenView
      .nextButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        didAcceptTerms = true
        if username != nil {
          navigator.perform(PresentChatList(on: navigationController!))
        } else {
          navigator.perform(PresentOnboardingUsername(on: navigationController!))
        }
      }.store(in: &cancellables)

    screenView
      .showTermsButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] _ in
        navigator.perform(PresentWebsite(urlString: "https://elixxir.io/eula", from: self))
      }.store(in: &cancellables)
  }
}
