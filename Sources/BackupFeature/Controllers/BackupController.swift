import UIKit
import Shared
import Combine
import AppResources

public final class BackupController: UIViewController {
  private let viewModel = BackupViewModel.live()
  private var cancellables = Set<AnyCancellable>()

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    navigationController?.navigationBar
      .customize(backgroundColor: Asset.neutralWhite.color)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Asset.neutralWhite.color
    setupNavigationBar()
    setupBindings()
  }

  private func setupNavigationBar() {
    let title = UILabel()
    title.text = Localized.Backup.header
    title.textColor = Asset.neutralActive.color
    title.font = Fonts.Mulish.semiBold.font(size: 18.0)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: title)
    navigationItem.leftItemsSupplementBackButton = true
  }

  private func setupBindings() {
    viewModel.state()
      .receive(on: DispatchQueue.main)
      .removeDuplicates()
      .sink { [unowned self] in
        switch $0 {
        case .setup:
          contentViewController = BackupSetupController(viewModel.setupViewModel())
        case .config:
          contentViewController = BackupConfigController(viewModel.configViewModel())
        }
      }.store(in: &cancellables)
  }

  private var contentViewController: UIViewController? {
    didSet {
      guard contentViewController != oldValue else { return }

      if let oldValue = oldValue {
        oldValue.willMove(toParent: nil)
        oldValue.view.removeFromSuperview()
        oldValue.removeFromParent()
      }

      if let newValue = contentViewController {
        addChild(newValue)
        view.addSubview(newValue.view)
        newValue.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        newValue.didMove(toParent: self)
      }
    }
  }
}
