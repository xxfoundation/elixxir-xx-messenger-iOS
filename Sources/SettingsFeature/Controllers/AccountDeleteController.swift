import HUD
import UIKit
import Popup
import Shared
import Combine
import Defaults
import ScrollViewController
import DependencyInjection

final class AccountDeleteController: UIViewController {
    @KeyObject(.username, defaultValue: "") var username: String

    @Dependency private var hud: HUDType
    @Dependency private var coordinator: SettingsCoordinating

    lazy private var screenView = AccountDeleteView()
    lazy private var scrollViewController = ScrollViewController()

    private let viewModel = AccountDeleteViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var popupCancellables = Set<AnyCancellable>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .customize(backgroundColor: Asset.neutralWhite.color)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupScrollView()
        setupBindings()

        screenView.update(username: username)

        screenView.setInfoClosure { [weak self] in
            self?.presentInfo(
                title: Localized.Settings.Delete.Info.title,
                subtitle: Localized.Settings.Delete.Info.subtitle
            )
        }
    }

    private func setupNavigationBar() {
        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
    }

    private func setupScrollView() {
        addChild(scrollViewController)
        view.addSubview(scrollViewController.view)
        scrollViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollViewController.didMove(toParent: self)
        scrollViewController.contentView = screenView
        scrollViewController.scrollView.backgroundColor = Asset.neutralWhite.color
    }

    private func setupBindings() {
        viewModel.hud
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        screenView.cancelButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in dismiss(animated: true) }
            .store(in: &cancellables)

        screenView.inputField.textPublisher
            .sink { [unowned self] in screenView.update(status: $0 == username ? .valid("") : .invalid("")) }
            .store(in: &cancellables)

        screenView.confirmButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in
                DispatchQueue.global().async { [weak self] in
                    self?.viewModel.didTapDelete()
                }
            }.store(in: &cancellables)

        screenView.cancelButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in navigationController?.popViewController(animated: true) }
            .store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    private func presentInfo(title: String, subtitle: String) {
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .seeThrough,
            title: Localized.Settings.InfoPopUp.action
        )

        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            PopupLabel(
                font: Fonts.Mulish.regular.font(size: 16.0),
                text: subtitle,
                color: Asset.neutralBody.color,
                alignment: .left,
                lineHeightMultiple: 1.1,
                spacingAfter: 37
            ),
            PopupStackView(views: [actionButton, FlexibleSpace()])
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
