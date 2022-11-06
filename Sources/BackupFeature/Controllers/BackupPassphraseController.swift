import UIKit
import Shared
import Combine
import InputField

public final class BackupPassphraseController: UIViewController {
  private lazy var screenView = BackupPassphraseView()

  private var passphrase = "" {
    didSet {
      switch Validator.backupPassphrase.validate(passphrase) {
      case .success:
        screenView.continueButton.isEnabled = true
      case .failure:
        screenView.continueButton.isEnabled = false
      }
    }
  }

  private let cancelClosure: EmptyClosure
  private let stringClosure: StringClosure
  private var cancellables = Set<AnyCancellable>()

  public init(
    _ cancelClosure: @escaping EmptyClosure,
    _ stringClosure: @escaping StringClosure
  ) {
    self.stringClosure = stringClosure
    self.cancelClosure = cancelClosure
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupBindings()
  }

  private func setupBindings() {
    screenView
      .inputField
      .returnPublisher
      .sink { [unowned self] in
        screenView.inputField.endEditing(true)
      }.store(in: &cancellables)

    screenView
      .inputField
      .textPublisher
      .sink { [unowned self] in
        passphrase = $0.trimmingCharacters(in: .whitespacesAndNewlines)
      }.store(in: &cancellables)

    screenView
      .continueButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        dismiss(animated: true) { self.stringClosure(self.passphrase) }
      }.store(in: &cancellables)

    screenView
      .cancelButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        dismiss(animated: true) { self.cancelClosure() }
      }.store(in: &cancellables)
  }
}
