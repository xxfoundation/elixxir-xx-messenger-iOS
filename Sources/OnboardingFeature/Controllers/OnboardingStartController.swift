import UIKit
import Combine
import AppNavigation
import ComposableArchitecture

public final class OnboardingStartController: UIViewController {
  @Dependency(\.navigator) var navigator

  private lazy var screenView = OnboardingStartView()

  private var cancellables = Set<AnyCancellable>()

  public override func loadView() {
    view = screenView
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    navigationController?.navigationBar
      .customize(translucent: true)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    screenView.gradientLayer.frame = screenView.bounds
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    screenView
      .startButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        navigator.perform(
          PresentTermsAndConditions(
            replacing: false,
            on: navigationController!
          ))
      }.store(in: &cancellables)
  }
}
