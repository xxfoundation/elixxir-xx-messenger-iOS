import UIKit
import Shared
import Combine
import AppCore
import Dependencies
import AppNavigation

public final class RestoreSuccessController: UIViewController {
  @Dependency(\.navigator) var navigator
  @Dependency(\.app.statusBar) var statusBar

  private lazy var screenView = RestoreSuccessView()
  private var cancellables = Set<AnyCancellable>()

  public override func loadView() {
    view = screenView
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    statusBar.set(.darkContent)
    navigationController?.navigationBar.customize(translucent: true)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupBindings()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    screenView.gradientLayer.frame = screenView.bounds
  }

  private func setupBindings() {
    screenView
      .nextButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        navigator.perform(PresentChatList(on: navigationController!))
      }.store(in: &cancellables)
  }
}
