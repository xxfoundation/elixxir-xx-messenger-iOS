import HUD
import UIKit
import Theme
import Shared
import Combine
import ContactFeature
import DependencyInjection

public final class RequestsContainerController: UIViewController {
    // MARK: UI

    lazy private var screenView = RequestsContainerView()

    // MARK: Injected

    @Dependency private var hud: HUDType
    @Dependency private var coordinator: RequestsCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    // MARK: Properties

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = RequestsContainerViewModel()

    // MARK: Lifecycle

    public override func loadView() {
        view = screenView

        screenView.scrollView.delegate = self

        addChild(screenView.sent)
        addChild(screenView.failed)
        addChild(screenView.received)

        screenView.sent.didMove(toParent: self)
        screenView.failed.didMove(toParent: self)
        screenView.received.didMove(toParent: self)

        screenView.bringSubviewToFront(screenView.segmentedControl)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)

        navigationController?.navigationBar
            .customize(backgroundColor: Asset.neutralWhite.color)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()

        if let stack = navigationController?.viewControllers, stack.count > 1 {
            if stack[stack.count - 2].isKind(of: ContactController.self) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }

                    let point = CGPoint(x: self.screenView.frame.width, y: 0.0)
                    self.screenView.scrollView.setContentOffset(point, animated: true)
                    self.screenView.segmentedControl.didChooseFilter(.sent)

                }
            }
        }
    }

    // MARK: Private

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""

        let title = UILabel()
        title.text = Localized.Requests.title
        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back, title])
        )
    }

    private func setupBindings() {
        viewModel.hud
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        screenView.received
            .hudPublisher
            .sink { [weak viewModel] in viewModel?.didReceive(hud: $0) }
            .store(in: &cancellables)

        screenView.sent
            .hudPublisher
            .sink { [weak viewModel] in viewModel?.didReceive(hud: $0) }
            .store(in: &cancellables)

        screenView.failed
            .hudPublisher
            .sink { [weak viewModel] in viewModel?.didReceive(hud: $0) }
            .store(in: &cancellables)

        screenView.received.verifyingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toVerifying(from: self) }
            .store(in: &cancellables)

        screenView.sent.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toContact($0, from: self) }
            .store(in: &cancellables)

        screenView.failed.didTap
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toContact($0, from: self) }
            .store(in: &cancellables)

        screenView.sent.emptyTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toSearch(from: self) }
            .store(in: &cancellables)

        screenView
            .segmentedControl.received
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in
                screenView.scrollView.setContentOffset(.zero, animated: true)
                screenView.segmentedControl.didChooseFilter(.received)
            }.store(in: &cancellables)

        screenView
            .segmentedControl.sent
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in
                let point = CGPoint(x: screenView.frame.width, y: 0.0)
                screenView.scrollView.setContentOffset(point, animated: true)
                screenView.segmentedControl.didChooseFilter(.sent)
            }.store(in: &cancellables)

        screenView
            .segmentedControl.failed
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in
                let point = CGPoint(x: screenView.frame.width * 2.0, y: 0.0)
                screenView.scrollView.setContentOffset(point, animated: true)
                screenView.segmentedControl.didChooseFilter(.failed)
            }.store(in: &cancellables)
    }

    // MARK: ObjC

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let percentage = scrollView.contentOffset.x / view.frame.width
        screenView.segmentedControl.updateLeftConstraint(percentage)
    }
}

extension RequestsContainerController: UIScrollViewDelegate {}
