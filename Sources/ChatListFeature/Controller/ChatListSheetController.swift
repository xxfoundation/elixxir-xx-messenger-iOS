import UIKit
import Combine

public final class ChatListSheetController: UIViewController {
  private lazy var screenView = ChatListMenuView()
  
  private let didTapDelete: () -> Void
  private let didTapDeleteAll: () -> Void
  private var cancellables = Set<AnyCancellable>()
  
  public init(
    _ didTapDelete: @escaping () -> Void,
    _ didTapDeleteAll: @escaping () -> Void
  ) {
    self.didTapDelete = didTapDelete
    self.didTapDeleteAll = didTapDeleteAll
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { nil }
  
  public override func loadView() {
    view = screenView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()

    screenView
      .deleteButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          self?.didTapDelete()
        }
      }.store(in: &cancellables)

    screenView
      .deleteAllButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          self?.didTapDeleteAll()
        }
      }.store(in: &cancellables)
  }
}
