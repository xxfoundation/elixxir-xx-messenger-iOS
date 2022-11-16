import UIKit
import Shared
import Combine
import Navigation
import DI

public final class RestoreSuccessController: UIViewController {
  @Dependency var navigator: Navigator
  @Dependency var barStylist: StatusBarStylist

  private lazy var screenView = RestoreSuccessView()
  private var cancellables = Set<AnyCancellable>()

  public override func loadView() {
    view = screenView
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    barStylist.styleSubject.send(.darkContent)
    navigationController?.navigationBar.customize(translucent: true)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupBindings()
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

  private func setupBindings() {
    screenView
      .nextButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        navigator.perform(PresentChatList(on: navigationController!))
      }.store(in: &cancellables)
  }
}
