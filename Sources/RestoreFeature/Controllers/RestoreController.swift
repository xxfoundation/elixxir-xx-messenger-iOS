import UIKit
import Shared
import Combine
import DrawerFeature
import DependencyInjection

public final class RestoreController: UIViewController {
    @Dependency private var coordinator: RestoreCoordinating

    lazy private var screenView = RestoreView()

    private let viewModel: RestoreViewModel
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

    public init(_ details: RestorationDetails) {
        viewModel = .init(details: details)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func loadView() {
        view = screenView
        presentWarning()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.customize(translucent: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()
    }

    private func setupNavigationBar() {
        let title = UILabel()
        title.text = Localized.AccountRestore.header
        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: title)
        navigationItem.leftItemsSupplementBackButton = true
    }

    private func setupBindings() {
      viewModel.stepPublisher
        .receive(on: DispatchQueue.main)
        .removeDuplicates()
        .sink { [unowned self] in
          screenView.updateFor(step: $0)

          if $0 == .wrongPass {
            coordinator.toPassphrase(
              from: self,
              cancelClosure: { self.dismiss(animated: true) },
              passphraseClosure: { pwd in
                self.viewModel.retryWith(passphrase: pwd)
              }
            )

            return
          }

          if $0 == .done {
            coordinator.toSuccess(from: self)
          }
        }.store(in: &cancellables)

      screenView.backButton
        .publisher(for: .touchUpInside)
        .sink { [unowned self] in didTapBack() }
        .store(in: &cancellables)

      screenView.cancelButton
        .publisher(for: .touchUpInside)
        .sink { [unowned self] in didTapBack() }
        .store(in: &cancellables)

      screenView.restoreButton
        .publisher(for: .touchUpInside)
        .sink { [unowned self] in
          coordinator.toPassphrase(
            from: self,
            cancelClosure: { self.dismiss(animated: true) },
            passphraseClosure: { pwd in
              self.viewModel.didTapRestore(passphrase: pwd)
            }
          )
        }.store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension RestoreController {
    private func presentWarning() {
        let actionButton = DrawerCapsuleButton(model: .init(
            title: Localized.AccountRestore.Warning.action,
            style: .brandColored
        ))

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.AccountRestore.Warning.title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            DrawerText(
                text: Localized.AccountRestore.Warning.subtitle,
                spacingAfter: 37
            ),
            actionButton
        ])

        actionButton.action
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                }
            }.store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }
}
