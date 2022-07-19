import UIKit
import Theme
import Shared
import Combine
import XXModels
import DrawerFeature
import DependencyInjection

public final class SearchContainerController: UIViewController {
    @Dependency var coordinator: SearchCoordinating
    @Dependency var statusBarController: StatusBarStyleControlling

    lazy private var screenView = SearchContainerView()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = SearchContainerViewModel()
    private let leftController = SearchLeftController()
    private let rightController = SearchRightController()
    private var drawerCancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
        embedControllers()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar.customize(
            backgroundColor: Asset.neutralWhite.color
        )
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = " "

        let titleLabel = UILabel()
        titleLabel.text = Localized.Ud.title
        titleLabel.textColor = Asset.neutralActive.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let backButton = UIButton.back()
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [backButton, titleLabel])
        )
    }

    private func setupBindings() {
        screenView.segmentedControl
            .actionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                if $0 == .qr {
                    let point = CGPoint(x: screenView.frame.width, y: 0.0)
                    screenView.scrollView.setContentOffset(point, animated: true)
                } else {
                    screenView.scrollView.setContentOffset(.zero, animated: true)
                    leftController.viewModel.didSelectItem($0)
                }
            }.store(in: &cancellables)

        viewModel.coverTrafficPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in presentCoverTrafficDrawer() }
            .store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    private func embedControllers() {
        addChild(leftController)
        addChild(rightController)

        screenView.scrollView.addSubview(leftController.view)
        screenView.scrollView.addSubview(rightController.view)

        leftController.view.snp.makeConstraints {
            $0.top.equalTo(screenView.segmentedControl.snp.bottom)
            $0.width.equalTo(screenView)
            $0.bottom.equalTo(screenView)
            $0.left.equalToSuperview()
            $0.right.equalTo(rightController.view.snp.left)
        }

        rightController.view.snp.makeConstraints {
            $0.top.equalTo(screenView.segmentedControl.snp.bottom)
            $0.width.equalTo(screenView)
            $0.bottom.equalTo(screenView)
        }

        leftController.didMove(toParent: self)
        rightController.didMove(toParent: self)
    }
}

extension SearchContainerController {
    private func presentCoverTrafficDrawer() {
        let enableButton = CapsuleButton()
        enableButton.set(
            style: .brandColored,
            title: Localized.ChatList.Traffic.positive
        )

        let dismissButton = CapsuleButton()
        dismissButton.set(
            style: .seeThrough,
            title: Localized.ChatList.Traffic.negative
        )

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.ChatList.Traffic.title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            DrawerText(
                font: Fonts.Mulish.regular.font(size: 16.0),
                text: Localized.ChatList.Traffic.subtitle,
                color: Asset.neutralBody.color,
                alignment: .left,
                lineHeightMultiple: 1.1,
                spacingAfter: 39
            ),
            DrawerStack(
                axis: .horizontal,
                spacing: 20,
                distribution: .fillEqually,
                views: [enableButton, dismissButton]
            )
        ])

        enableButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                    self.viewModel.didEnableCoverTraffic()
                }
            }.store(in: &drawerCancellables)

        dismissButton
            .publisher(for: .touchUpInside)
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
