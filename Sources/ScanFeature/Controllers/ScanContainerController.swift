import UIKit
import Theme
import Shared
import Combine
import DrawerFeature
import DependencyInjection

public final class ScanContainerController: UIViewController {
    @Dependency private var coordinator: ScanCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = ScanContainerView()

    private let scanController = ScanController()
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()
    private let displayController = ScanDisplayController()
    private let pageController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )

    public override func loadView() {
        view = screenView

        addChild(pageController)
        screenView.addSubview(pageController.view)
        pageController.view.snp.makeConstraints {
            $0.top.equalTo(screenView.stackView.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(screenView)
        }

        pageController.delegate = self
        pageController.dataSource = self
        pageController.didMove(toParent: self)
        pageController.setViewControllers([scanController], direction: .forward, animated: true)
        screenView.bringSubviewToFront(screenView.stackView)
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

        displayController.didTapInfo = { [weak self] in
            self?.presentInfo(
                title: Localized.Scan.Info.title,
                subtitle: Localized.Scan.Info.subtitle
            )
        }

        displayController.didTapAddEmail = { [weak self] in
            guard let self = self else { return }
            self.coordinator.toEmail(from: self)
        }

        displayController.didTapAddPhone = { [weak self] in
            guard let self = self else { return }
            self.coordinator.toPhone(from: self)
        }
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let titleLabel = UILabel()
        titleLabel.text = "QR Code"
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)
        titleLabel.textColor = Asset.neutralWhite.color

        let menuButton = UIButton()
        menuButton.tintColor = Asset.neutralWhite.color
        menuButton.setImage(Asset.chatListMenu.image, for: .normal)
        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
        menuButton.snp.makeConstraints { $0.width.equalTo(50) }

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [menuButton, titleLabel])
        )
    }

    private func setupBindings() {
        screenView.leftButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in
                screenView.leftButton.set(selected: true)
                screenView.rightButton.set(selected: false)
                pageController.setViewControllers([scanController], direction: .reverse, animated: true, completion: nil)
            }.store(in: &cancellables)

        screenView.rightButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in
                screenView.leftButton.set(selected: false)
                screenView.rightButton.set(selected: true)
                pageController.setViewControllers([displayController], direction: .forward, animated: true, completion: nil)
            }.store(in: &cancellables)
    }

    @objc private func didTapMenu() {
        coordinator.toSideMenu(from: self)
    }

    private func presentInfo(title: String, subtitle: String) {
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .seeThrough,
            title: Localized.Settings.InfoDrawer.action
        )

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            DrawerText(
                font: Fonts.Mulish.regular.font(size: 16.0),
                text: subtitle,
                color: Asset.neutralBody.color,
                alignment: .left,
                lineHeightMultiple: 1.1,
                spacingAfter: 37
            ),
            DrawerStack(views: [
                actionButton,
                FlexibleSpace()
            ])
        ])

        actionButton.publisher(for: .touchUpInside)
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

extension ScanContainerController: UIPageViewControllerDataSource {
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard viewController != displayController else { return nil }
        return displayController
    }

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard viewController != scanController else { return nil }
        return scanController
    }
}


extension ScanContainerController: UIPageViewControllerDelegate {
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard finished, completed else { return }

        if previousViewControllers.contains(scanController) {
            screenView.leftButton.set(selected: false)
            screenView.rightButton.set(selected: true)
        } else {
            screenView.leftButton.set(selected: true)
            screenView.rightButton.set(selected: false)
        }
    }
}
