import HUD
import UIKit
import Shared
import Combine
import Defaults
import PushFeature
import DependencyInjection

public final class LaunchController: UIViewController {
    @Dependency private var hud: HUD
    @Dependency private var coordinator: LaunchCoordinating

    @KeyObject(.acceptedTerms, defaultValue: false) var didAcceptTerms: Bool

    lazy private var screenView = LaunchView()

    private let blocker = UpdateBlocker()
    private let viewModel = LaunchViewModel()
    public var pendingPushRoute: PushRouter.Route?
    private var cancellables = Set<AnyCancellable>()

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }

    public override func loadView() {
        view = screenView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?
            .navigationBar
            .customize(translucent: true)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        screenView.setupGradient()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.hudPublisher
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        viewModel.routePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                switch $0 {
                case .chats:
                    guard didAcceptTerms == true else {
                        coordinator.toTerms(from: self)
                        return
                    }

                    if let pushRoute = pendingPushRoute {
                        switch pushRoute {
                        case .requests:
                            coordinator.toRequests(from: self)

                        case .search(username: let username):
                            coordinator.toSearch(searching: username, from: self)

                        case .groupChat(id: let groupId):
                            if let groupInfo = viewModel.getGroupInfoWith(groupId: groupId) {
                                coordinator.toGroupChat(with: groupInfo, from: self)
                                return
                            }
                            coordinator.toChats(from: self)

                        case .contactChat(id: let userId):
                            if let contact = viewModel.getContactWith(userId: userId) {
                                coordinator.toSingleChat(with: contact, from: self)
                                return
                            }
                            coordinator.toChats(from: self)
                        }

                        return
                    }

                    coordinator.toChats(from: self)

                case .onboarding:
                    coordinator.toOnboarding(from: self)

                case .update(let model):
                    offerUpdate(model: model)
                }
            }.store(in: &cancellables)
    }

    private func offerUpdate(model: Update) {
        let drawerView = UIView()
        drawerView.backgroundColor = Asset.neutralSecondary.color
        drawerView.layer.cornerRadius = 5

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 10
        drawerView.addSubview(vStack)

        vStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.left.equalToSuperview().offset(18)
            $0.right.equalToSuperview().offset(-18)
            $0.bottom.equalToSuperview().offset(-18)
        }

        let title = UILabel()
        title.text = "App Update"
        title.textAlignment = .center
        title.textColor = Asset.neutralDark.color

        let body = UILabel()
        body.numberOfLines = 0
        body.textAlignment = .center
        body.textColor = Asset.neutralDark.color

        let update = CapsuleButton()
        update.publisher(for: .touchUpInside)
            .sink { UIApplication.shared.open(.init(string: model.urlString)!, options: [:]) }
            .store(in: &cancellables)

        vStack.addArrangedSubview(title)
        vStack.addArrangedSubview(body)
        vStack.addArrangedSubview(update)

        body.text = model.content
        update.set(
            style: model.actionStyle,
            title: model.positiveActionTitle
        )

        if let negativeTitle = model.negativeActionTitle {
            let negativeButton = CapsuleButton()
            negativeButton.set(style: .simplestColoredRed, title: negativeTitle)

            negativeButton.publisher(for: .touchUpInside)
                .sink { [unowned self] in
                    blocker.hideWindow()
                    viewModel.continueWithInitialization()
                }.store(in: &cancellables)

            vStack.addArrangedSubview(negativeButton)
        }

        blocker.window?.addSubview(drawerView)
        drawerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(18)
            $0.center.equalToSuperview()
            $0.right.equalToSuperview().offset(-18)
        }

        blocker.showWindow()
    }
}
