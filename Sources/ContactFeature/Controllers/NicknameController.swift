import UIKit
import Shared
import Combine
import InputField
import ScrollViewController

public final class NicknameController: UIViewController {
    private lazy var screenView = NicknameView()

    private let prefilled: String
    private let completion: StringClosure
    private let viewModel = NicknameViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let keyboardListener = KeyboardFrameChangeListener(notificationCenter: .default)

    public init(_ prefilled: String, _ completion: @escaping StringClosure) {
        self.prefilled = prefilled
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func loadView() {
        let view = UIView()
        view.addSubview(screenView)

        screenView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(0)
        }

        self.view = view
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
        setupBindings()

        screenView.inputField.update(content: prefilled)
        viewModel.didInput(prefilled)
    }

    private func setupKeyboard() {
        keyboardListener.keyboardFrameWillChange = { [weak self] keyboard in
            guard let self else { return }

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
        viewModel.state
            .map(\.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak screenView] in screenView?.update(status: $0) }
            .store(in: &cancellables)

        viewModel.done
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true)
                completion($0)
            }.store(in: &cancellables)

        screenView.inputField.textPublisher
            .sink { [weak viewModel] in viewModel?.didInput($0) }
            .store(in: &cancellables)

        screenView.saveButton.publisher(for: .touchUpInside)
            .sink { [weak viewModel] in viewModel?.didTapSave() }
            .store(in: &cancellables)
    }
}
