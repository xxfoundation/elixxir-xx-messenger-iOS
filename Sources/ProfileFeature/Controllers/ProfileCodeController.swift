import UIKit
import Shared
import Combine
import AppCore
import AppResources
import Dependencies
import AppNavigation
import ScrollViewController

public final class ProfileCodeController: UIViewController {
  @Dependency(\.navigator) var navigator
  @Dependency(\.app.statusBar) var statusBar

  private lazy var screenView = ProfileCodeView()
  private lazy var scrollViewController = ScrollViewController()

  private let isEmail: Bool
  private let content: String
  private let viewModel: ProfileCodeViewModel
  private var cancellables = Set<AnyCancellable>()

  public init(
    _ isEmail: Bool,
    _ content: String,
    _ confirmationId: String
  ) {
    self.viewModel = .init(
      isEmail: isEmail,
      content: content,
      confirmationId: confirmationId
    )
    self.isEmail = isEmail
    self.content = content
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    navigationController?.navigationBar
      .customize(backgroundColor: Asset.neutralWhite.color)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupScrollView()
    setupBindings()

    if isEmail {
      screenView.set(content, isEmail: true)
    } else {
      let country = Country.findFrom(content)
      screenView.set(
        "\(country.prefix)\(content.dropLast(2))",
        isEmail: false
      )
    }
  }

  private func setupScrollView() {
    scrollViewController.contentView = screenView
    scrollViewController.scrollView.backgroundColor = Asset.neutralWhite.color
    addChild(scrollViewController)
    view.addSubview(scrollViewController.view)
    scrollViewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scrollViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      scrollViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      scrollViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])
    view.setNeedsLayout()
    view.layoutIfNeeded()
    scrollViewController.didMove(toParent: self)
  }

  private func setupBindings() {
    screenView
      .inputField
      .textPublisher
      .sink { [unowned self] in
        viewModel.didInput($0)
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.status)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        switch $0 {
        case .valid:
          screenView.saveButton.isEnabled = true
        case .invalid, .unknown:
          screenView.saveButton.isEnabled = false
        }
      }.store(in: &cancellables)

    screenView
      .saveButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        viewModel.didTapNext()
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.resendDebouncer)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.resendButton.isEnabled = $0 == 0
        if $0 == 0 {
          screenView.resendButton.setTitle(
            Localized.Profile.Code.resend(""), for: .normal
          )
        } else {
          screenView.resendButton.setTitle(
            Localized.Profile.Code.resend("(\($0))"), for: .disabled
          )
        }
      }.store(in: &cancellables)

    screenView
      .resendButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        viewModel.didTapResend()
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.didConfirm)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard let navigationController, $0 == true else { return }
        navigator.perform(PopToRoot(on: navigationController))
      }.store(in: &cancellables)
  }
}
