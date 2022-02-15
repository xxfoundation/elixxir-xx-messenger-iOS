import UIKit
import Combine

public final class ChatListSheetController: UIViewController {
    public enum Action {
        case delete
        case deleteAll
    }

    lazy private var screenView = ChatListMenuView()

    var didChooseAction: (Action) -> Void
    private var cancellables = Set<AnyCancellable>()

    public init(_ didChooseAction: @escaping ChatListSheetClosure) {
        self.didChooseAction = didChooseAction
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
        screenView.deleteButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in dismiss(animated: true) { [weak self] in self?.didChooseAction(.delete) }}
            .store(in: &cancellables)

        screenView.deleteAllButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in dismiss(animated: true) { [weak self] in self?.didChooseAction(.deleteAll) }}
            .store(in: &cancellables)
    }
}
