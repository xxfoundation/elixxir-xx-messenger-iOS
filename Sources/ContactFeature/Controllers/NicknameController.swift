import UIKit
import Combine

public final class NicknameController: UIViewController {
  private lazy var screenView = NicknameView()

  private let viewModel: NicknameViewModel
  private let completion: (String) -> Void
  private var cancellables = Set<AnyCancellable>()

  public init(
    _ prefilled: String,
    _ completion: @escaping (String) -> Void
  ) {
    self.completion = completion
    self.viewModel = .init(prefilled: prefilled)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    viewModel
      .statePublisher
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.inputField.update(status: $0.status)
        screenView.inputField.update(content: $0.input)

        if case .valid = $0.status {
          screenView.saveButton.isEnabled = true
        } else {
          screenView.saveButton.isEnabled = false
        }
      }.store(in: &cancellables)

    screenView
      .inputField
      .textPublisher
      .sink { [unowned self] in
        viewModel.didInput($0)
      }.store(in: &cancellables)

    screenView
      .saveButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self else { return }
          self.completion(self.viewModel.getInput())
        }
      }.store(in: &cancellables)
  }
}
