import HUD
import UIKit
import Shared
import Models
import Combine
import DependencyInjection

public final class BackupController: UIViewController {
    @Dependency private var hud: HUDType

    private let viewModel = BackupViewModel.live()
    private var cancellables = Set<AnyCancellable>()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.neutralWhite.color
        hud.update(with: .on)

        setupNavigationBar()
        setupBindings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let title = UILabel()
        title.text = Localized.Backup.header
        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back, title])
        )
    }

    private func setupBindings() {
        viewModel.state()
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [unowned self] in
                hud.update(with: .none)

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

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
