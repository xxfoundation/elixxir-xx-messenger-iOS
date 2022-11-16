import DI
import UIKit
import Shared
import Combine
import Navigation
import ScrollViewController

public final class ProfileEmailController: UIViewController {
  @Dependency var navigator: Navigator
  @Dependency var barStylist: StatusBarStylist

  private lazy var screenView = ProfileEmailView()
  private lazy var scrollViewController = ScrollViewController()

  private let viewModel = ProfileEmailViewModel()
  private var cancellables = Set<AnyCancellable>()

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    barStylist.styleSubject.send(.darkContent)
    navigationController?.navigationBar.customize(backgroundColor: Asset.neutralWhite.color)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupScrollView()
    setupBindings()
  }

  private func setupScrollView() {
    addChild(scrollViewController)
    view.addSubview(scrollViewController.view)
    scrollViewController.view.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    scrollViewController.didMove(toParent: self)
    scrollViewController.contentView = screenView
    scrollViewController.scrollView.backgroundColor = Asset.neutralWhite.color
  }

  private func setupBindings() {
    screenView
      .inputField
      .textPublisher
      .sink { [unowned self] in
        viewModel.didInput($0)
      }.store(in: &cancellables)

    screenView
      .inputField
      .returnPublisher
      .sink { [unowned self] in
        screenView.inputField.endEditing(true)
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard let id = $0.confirmationId else { return }
        viewModel.clearUp()
        navigator.perform(
          PresentProfileCode(
            isEmail: true,
            content: $0.input,
            confirmationId: id,
            on: navigationController!
          )
        )
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.status)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.update(status: $0)
      }.store(in: &cancellables)

    screenView
      .saveButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        viewModel.didTapNext()
      }.store(in: &cancellables)
  }
}
