import UIKit
import Combine

public final class ChatMoreController: UIViewController {
  private lazy var screenView = ChatMoreView()

  private let didTapClear: () -> Void
  private let didTapReport: () -> Void
  private let didTapDetails: () -> Void
  private var cancellables = Set<AnyCancellable>()

  public init(
    _ didTapClear: @escaping () -> Void,
    _ didTapReport: @escaping () -> Void,
    _ didTapDetails: @escaping () -> Void
  ) {
    self.didTapClear = didTapClear
    self.didTapReport = didTapReport
    self.didTapDetails = didTapDetails
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    screenView
      .clearButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in didTapClear() }
      .store(in: &cancellables)

    screenView
      .detailsButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in didTapDetails() }
      .store(in: &cancellables)

    screenView
      .reportButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in didTapReport() }
      .store(in: &cancellables)
  }
}
