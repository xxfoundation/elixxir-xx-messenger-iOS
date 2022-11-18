import UIKit
import Combine
import ScrollViewController

public final class RestoreSFTPController: UIViewController {
  private lazy var screenView = RestoreSFTPView()
  private lazy var scrollViewController = ScrollViewController()

  private let completion: (String, String, String) -> Void
  private let viewModel = RestoreSFTPViewModel()
  private var cancellables = Set<AnyCancellable>()

  public init(_ completion: @escaping (String, String, String) -> Void) {
    self.completion = completion
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    navigationController?.navigationBar.customize(translucent: true)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupScrollView()
    setupBindings()
  }

  private func setupScrollView() {
    scrollViewController.scrollView.backgroundColor = .white

    addChild(scrollViewController)
    view.addSubview(scrollViewController.view)
    scrollViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
    scrollViewController.didMove(toParent: self)
    scrollViewController.contentView = screenView
  }

  private func setupBindings() {
    viewModel.authPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] params in
        dismiss(animated: true) {
          self.completion(params.0, params.1, params.2)
        }
      }.store(in: &cancellables)

    screenView.hostField
      .textPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in viewModel.didEnterHost($0) }
      .store(in: &cancellables)

    screenView.usernameField
      .textPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in viewModel.didEnterUsername($0) }
      .store(in: &cancellables)

    screenView.passwordField
      .textPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in viewModel.didEnterPassword($0) }
      .store(in: &cancellables)

    viewModel.statePublisher
      .receive(on: DispatchQueue.main)
      .map(\.isButtonEnabled)
      .sink { [unowned self] in screenView.loginButton.isEnabled = $0 }
      .store(in: &cancellables)

    screenView.loginButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in viewModel.didTapLogin() }
      .store(in: &cancellables)
  }
}
