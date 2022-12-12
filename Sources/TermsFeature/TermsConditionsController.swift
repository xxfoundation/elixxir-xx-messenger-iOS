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
    screenView.gradientLayer.frame = screenView.bounds
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
