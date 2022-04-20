import UIKit
import Shared
import Combine
import InputField
import ScrollViewController

public final class RestorePassphraseController: UIViewController {
    lazy private var screenView = RestorePassphraseView()

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

    private let completion: StringClosure
    private var cancellables = Set<AnyCancellable>()
    private let keyboardListener = KeyboardFrameChangeListener(notificationCenter: .default)

    public init(_ completion: @escaping StringClosure) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func loadView() {
        let view = UIView()
        view.addSubview(screenView)

        screenView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }

        self.view = view
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
        setupBindings()

        screenView.continueButton.isEnabled = false
    }

    private func setupKeyboard() {
        keyboardListener.keyboardFrameWillChange = { [weak self] keyboard in
            guard let self = self else { return }

            let inset = self.view.frame.height - self.view.convert(keyboard.frame, from: nil).minY

            self.screenView.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-inset)
            }

            self.view.setNeedsLayout()

            UIView.animate(withDuration: keyboard.animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    private func setupBindings() {
        screenView.inputField.returnPublisher
            .sink { [unowned self] in screenView.inputField.endEditing(true) }
            .store(in: &cancellables)

        screenView.cancelButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in dismiss(animated: true) }
            .store(in: &cancellables)

        screenView.inputField
            .textPublisher
            .sink { [unowned self] in passphrase = $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .store(in: &cancellables)

        screenView.continueButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in
                dismiss(animated: true, completion: { self.completion(self.passphrase) })
            }.store(in: &cancellables)
    }
}
