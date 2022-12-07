import UIKit
import Combine

public final class RetryMessageController: UIViewController {
  private lazy var screenView = RetryMessageView()

  private let didTapRetry: () -> Void
  private let didTapDelete: () -> Void
  private let didTapCancel: () -> Void
  private var cancellables = Set<AnyCancellable>()

  public init(
    _ didTapRetry: @escaping () -> Void,
    _ didTapDelete: @escaping () -> Void,
    _ didTapCancel: @escaping () -> Void
  ) {
    self.didTapRetry = didTapRetry
    self.didTapDelete = didTapDelete
    self.didTapCancel = didTapCancel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    screenView
      .retryButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in didTapRetry() }
      .store(in: &cancellables)

    screenView
      .deleteButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in didTapDelete() }
      .store(in: &cancellables)

    screenView
      .cancelButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in didTapCancel() }
      .store(in: &cancellables)
  }
}
