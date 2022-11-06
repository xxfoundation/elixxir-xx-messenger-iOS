import UIKit
import Shared
import Combine

public final class CreateDrawerController: UIViewController {
    private lazy var screenView = CreateDrawerView()

    private let selectedCount: Int
    private let viewModel = CreateDrawerViewModel()
    private let completion: (String, String?) -> Void
    private var cancellables = Set<AnyCancellable>()

    public init(_ count: Int, _ completion: @escaping (String, String?) -> Void) {
        self.selectedCount = count
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
        screenView.set(count: selectedCount) {
            // TODO: ⚠️
        }

        setupBindings()
    }

    private func setupBindings() {
        viewModel.statePublisher
            .map(\.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak screenView] in screenView?.update(status: $0) }
            .store(in: &cancellables)

        viewModel.donePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                dismiss(animated: true)
                completion($0.0, $0.1)
            }.store(in: &cancellables)

        screenView.cancelButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in dismiss(animated: true) }
            .store(in: &cancellables)

        screenView.inputField
            .textPublisher
            .sink { [weak viewModel] in viewModel?.didInput($0) }
            .store(in: &cancellables)

        screenView.otherInputField
            .textPublisher
            .sink { [weak viewModel] in viewModel?.didOtherInput($0) }
            .store(in: &cancellables)

        screenView.inputField
            .returnPublisher
            .sink { [unowned self] in screenView.inputField.endEditing(true) }
            .store(in: &cancellables)

        screenView.otherInputField
            .returnPublisher
            .sink { [unowned self] in screenView.otherInputField.endEditing(true) }
            .store(in: &cancellables)

        screenView.createButton
            .publisher(for: .touchUpInside)
            .sink { [weak viewModel] in viewModel?.didTapCreate() }
            .store(in: &cancellables)
    }
}
