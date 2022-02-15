import HUD
import Theme
import UIKit
import Shared
import Combine
import DependencyInjection
import ScrollViewController
import Popup

public final class SearchController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: SearchCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var tableController = SearchTableController(viewModel)
    lazy private var screenView = SearchView {
        let actionButton = CapsuleButton()
        actionButton.set(
            style: .seeThrough,
            title: Localized.ContactSearch.Placeholder.Popup.action
        )

        let popup = BottomPopup(with: [
            PopupLabel(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: Localized.ContactSearch.Placeholder.Popup.title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            PopupLinkText(
                text: Localized.ContactSearch.Placeholder.Popup.subtitle,
                urlString: "https://links.xx.network/adrp",
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
            }.store(in: &self.popupCancellables)

        self.coordinator.toPopup(popup, from: self)
    }

    private let viewModel = SearchViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var popupCancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)

        navigationController?.navigationBar.customize(
            backgroundColor: Asset.neutralWhite.color,
            shadowColor: Asset.neutralDisabled.color
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupBindings()
        setupFilterBindings()
    }

    private func setupTableView() {
        addChild(tableController)
        screenView.addSubview(tableController.view)

        tableController.view.snp.makeConstraints { make in
            make.top.equalTo(screenView.stack.snp.bottom).offset(20)
            make.left.bottom.right.equalToSuperview()
        }

        tableController.didMove(toParent: self)
        tableController.tableView.delegate = self
        screenView.bringSubviewToFront(screenView.empty)
        screenView.bringSubviewToFront(screenView.placeholder)
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = " "

        let title = UILabel()
        title.text = Localized.ContactSearch.title
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
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        viewModel
            .itemsRelay
            .removeDuplicates()
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.empty.isHidden = $0 > 0 }
            .store(in: &cancellables)

        viewModel.placeholderPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in screenView.placeholder.isHidden = !$0 }
            .store(in: &cancellables)

        viewModel.state
            .map(\.country)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                screenView.phoneInput.set(prefix: $0.prefixWithFlag)
                screenView.phoneInput.update(placeholder: $0.example)
            }
            .store(in: &cancellables)

        screenView.input
            .textPublisher
            .removeDuplicates()
            .compactMap { $0 }
            .sink { [unowned self] in viewModel.didInput($0) }
            .store(in: &cancellables)

        screenView.input
            .returnPublisher
            .sink { [unowned self] in viewModel.didTapSearch() }
            .store(in: &cancellables)

        screenView.phoneInput
            .returnPublisher
            .sink { [unowned self] in viewModel.didTapSearch() }
            .store(in: &cancellables)

        screenView
            .phoneInput
            .textPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in viewModel.didInputPhone($0) }
            .store(in: &cancellables)

        screenView
            .phoneInput
            .codePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toCountries(from: self) { viewModel.didChooseCountry($0) }}
            .store(in: &cancellables)
    }

    private func setupFilterBindings() {
        screenView.username
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in viewModel.didSelect(filter: .username) }
            .store(in: &cancellables)

        screenView.phone
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in viewModel.didSelect(filter: .phone) }
            .store(in: &cancellables)

        screenView.email
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in viewModel.didSelect(filter: .email) }
            .store(in: &cancellables)

        viewModel.state
            .map(\.selectedFilter)
            .removeDuplicates()
            .sink { [unowned self] in screenView.alternateFieldsOver(filter: $0) }
            .store(in: &cancellables)

        viewModel.state
            .map(\.selectedFilter)
            .removeDuplicates()
            .dropFirst()
            .sink { [unowned self] in screenView.select(filter: $0) }
            .store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        coordinator.toContact(viewModel.itemsRelay.value[indexPath.row], from: self)
    }
}

extension SearchController: UITableViewDelegate {}
