import UIKit
import Models
import Shared
import Popup
import Combine
import DependencyInjection

public final class RestoreController: UIViewController {
    @Dependency private var coordinator: RestoreCoordinating

    lazy private var screenView = RestoreView()

    private let viewModel: RestoreViewModel
    private var cancellables = Set<AnyCancellable>()
    private var popupCancellables = Set<AnyCancellable>()

    public init(_ ndf: String, _ settings: RestoreSettings) {
        viewModel = .init(ndf: ndf, settings: settings)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func loadView() {
        view = screenView
        presentWarning()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let title = UILabel()
        title.text = Localized.Restore.header
        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back, title])
        )
    }

    private func setupBindings() {
        viewModel.step
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [unowned self] in
                screenView.updateFor(step: $0)

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
            .sink { [unowned self] in viewModel.didTapRestore() }
            .store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension RestoreController {
    private func presentWarning() {
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .brandColored,
            title: Localized.Restore.Warning.action
        )

        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.Restore.Warning.title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            PopupLabelAttributed(
                text: Localized.Restore.Warning.subtitle,
                spacingAfter: 37
            ),
            PopupStackView(views: [actionButton])
        ])

        actionButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                popup.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.popupCancellables.removeAll()
                }
            }.store(in: &popupCancellables)

        coordinator.toPopup(popup, from: self)
    }
}
