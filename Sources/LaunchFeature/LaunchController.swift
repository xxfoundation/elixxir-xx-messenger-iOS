import UIKit
import Shared
import Combine
import Navigation
import PushFeature
import DependencyInjection

public final class LaunchController: UIViewController {
  @Dependency var navigator: Navigator

  // TO REMOVE:
  public var pendingPushRoute: PushRouter.Route?

  private let viewModel = LaunchViewModel()
  private lazy var screenView = LaunchView()
  private var cancellables = Set<AnyCancellable>()

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.viewDidAppear()
  }

  public override func loadView() {
    view = screenView
  }

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

    gradient.frame = screenView.bounds
    gradient.startPoint = CGPoint(x: 1, y: 0)
    gradient.endPoint = CGPoint(x: 0, y: 1)
    screenView.layer.insertSublayer(gradient, at: 0)
  }

  private func offerUpdate(model: Update) {
    let drawerView = UIView()
    drawerView.backgroundColor = Asset.neutralSecondary.color
    drawerView.layer.cornerRadius = 5

    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.spacing = 10
    drawerView.addSubview(vStack)

    vStack.snp.makeConstraints {
      $0.top.equalToSuperview().offset(18)
      $0.left.equalToSuperview().offset(18)
      $0.right.equalToSuperview().offset(-18)
      $0.bottom.equalToSuperview().offset(-18)
    }

    let title = UILabel()
    title.text = "App Update"
    title.textAlignment = .center
    title.textColor = Asset.neutralDark.color

    let body = UILabel()
    body.numberOfLines = 0
    body.textAlignment = .center
    body.textColor = Asset.neutralDark.color

    let update = CapsuleButton()
    update.publisher(for: .touchUpInside)
      .sink { UIApplication.shared.open(.init(string: model.urlString)!, options: [:]) }
      .store(in: &cancellables)

    vStack.addArrangedSubview(title)
    vStack.addArrangedSubview(body)
    vStack.addArrangedSubview(update)

    body.text = model.content
    update.set(
      style: model.actionStyle,
      title: model.positiveActionTitle
    )

    //    if let negativeTitle = model.negativeActionTitle {
    //      let negativeButton = CapsuleButton()
    //      negativeButton.set(style: .simplestColoredRed, title: negativeTitle)
    //
    //      negativeButton.publisher(for: .touchUpInside)
    //        .sink { [unowned self] in
    //          blocker.hideWindow()
    //          viewModel.continueWithInitialization()
    //        }.store(in: &cancellables)
    //
    //      vStack.addArrangedSubview(negativeButton)
    //    }
    //
    //    blocker.window?.addSubview(drawerView)
    //    drawerView.snp.makeConstraints {
    //      $0.left.equalToSuperview().offset(18)
    //      $0.center.equalToSuperview()
    //      $0.right.equalToSuperview().offset(-18)
    //    }
    //
    //    blocker.showWindow()
  }
}
