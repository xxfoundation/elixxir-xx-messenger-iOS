import UIKit
import Combine
import XXModels

public final class CreateGroupController: UIViewController {
  private lazy var screenView = CreateGroupView()

  private let groupMembers: [Contact]
  private let viewModel = CreateGroupViewModel()
  private var cancellables = Set<AnyCancellable>()

  public init(_ groupMembers: [Contact]) {
    self.groupMembers = groupMembers
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    screenView.set(count: groupMembers.count, didTap: {})

    viewModel
      .statePublisher
      .map(\.status)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.update(status: $0)
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.shouldDismiss)
      .filter { $0 == true }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        dismiss(animated: true)
      }.store(in: &cancellables)

    screenView
      .cancelButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true)
      }.store(in: &cancellables)

    screenView
      .inputField
      .textPublisher
      .sink { [unowned self] in
        viewModel.didInput($0)
      }.store(in: &cancellables)

    screenView
      .otherInputField
      .textPublisher
      .sink { [unowned self] in
        viewModel.didOtherInput($0)
      }.store(in: &cancellables)

    screenView
      .inputField
      .returnPublisher
      .sink { [unowned self] in
        screenView.inputField.endEditing(true)
      }.store(in: &cancellables)

    screenView
      .otherInputField
      .returnPublisher
      .sink { [unowned self] in
        screenView.otherInputField.endEditing(true)
      }.store(in: &cancellables)

    screenView
      .createButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        viewModel.didTapCreate(groupMembers)
      }.store(in: &cancellables)
  }
}
