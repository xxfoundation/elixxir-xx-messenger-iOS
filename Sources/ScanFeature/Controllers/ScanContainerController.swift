import UIKit
import Popup
import Theme
import Shared
import Combine
import DependencyInjection

public final class ScanContainerController: UIViewController {
    @Dependency private var coordinator: ScanCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = ScanContainerView()

    private var cancellables = Set<AnyCancellable>()
    private var popupCancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView

        screenView.scrollView.delegate = self
        addChild(screenView.scanScreen)
        screenView.scanScreen.didMove(toParent: self)

        addChild(screenView.displayScreen)
        screenView.displayScreen.didMove(toParent: self)
        screenView.bringSubviewToFront(screenView.segmentedControl)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.lightContent)
        navigationController?.navigationBar.customize(translucent: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()

        screenView.displayScreen.didTapInfo = { [weak self] in
            self?.presentInfo(
                title: Localized.Scan.Info.title,
                subtitle: Localized.Scan.Info.subtitle
            )
        }
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
        let titleLabel = UILabel()

        titleLabel.text = "QR Code"
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)
        titleLabel.textColor = Asset.neutralWhite.color

        let back = UIButton.back(color: Asset.neutralWhite.color)
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back, titleLabel])
        )
    }

    private func setupBindings() {
        screenView.segmentedControl.leftButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in screenView.scrollView.setContentOffset(.zero, animated: true) }
            .store(in: &cancellables)

        screenView.segmentedControl.rightButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in
                let point = CGPoint(x: screenView.frame.width, y: 0.0)
                screenView.scrollView.setContentOffset(point, animated: true)
            }.store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let percentage = scrollView.contentOffset.x / view.frame.width

        screenView.scanScreen.view.alpha = 1 - percentage
        screenView.displayScreen.view.alpha = percentage
        screenView.segmentedControl.updateLeftConstraint(percentage)
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

extension ScanContainerController: UIScrollViewDelegate {}
