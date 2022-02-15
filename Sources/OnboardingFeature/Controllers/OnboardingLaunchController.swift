import HUD
import UIKit
import Theme
import Shared
import Combine
import DependencyInjection

public final class OnboardingLaunchController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: OnboardingCoordinating

    private var imageView = UIImageView()
    private let blocker = UpdateBlocker()
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = OnboardingLaunchViewModel()

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.viewModel.didFinishSplash()
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.customize(translucent: true)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 122/255, green: 235/255, blue: 239/255, alpha: 1).cgColor,
            UIColor(red: 56/255, green: 204/255, blue: 232/255, alpha: 1).cgColor,
            UIColor(red: 63/255, green: 186/255, blue: 253/255, alpha: 1).cgColor,
            UIColor(red: 98/255, green: 163/255, blue: 255/255, alpha: 1).cgColor
        ]

        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)

        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.neutralWhite.color

        imageView.image = Asset.splash.image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(100)
        }

        viewModel.hud
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

        viewModel.chatsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toChats(from: self) }
            .store(in: &cancellables)

        viewModel.usernamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toStart(with: $0, from: self) }
            .store(in: &cancellables)

        viewModel.updatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] updateModel in
                let popupView = UIView()
                popupView.backgroundColor = Asset.neutralSecondary.color
                popupView.layer.cornerRadius = 5

                let vStack = UIStackView()
                vStack.axis = .vertical
                vStack.spacing = 10
                popupView.addSubview(vStack)

                vStack.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(18)
                    make.left.equalToSuperview().offset(18)
                    make.right.equalToSuperview().offset(-18)
                    make.bottom.equalToSuperview().offset(-18)
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
                    .sink { UIApplication.shared.open(.init(string: updateModel.appUrl)!, options: [:]) }
                    .store(in: &cancellables)

                vStack.addArrangedSubview(title)
                vStack.addArrangedSubview(body)
                vStack.addArrangedSubview(update)

                body.text = updateModel.body
                update.set(
                    style: updateModel.updateStyle,
                    title: updateModel.updateTitle
                )

                if let notNowTitle = updateModel.notNowTitle {
                    let notNow = CapsuleButton()
                    notNow.set(style: .simplestColored, title: notNowTitle)

                    notNow.publisher(for: .touchUpInside)
                        .sink { [unowned self] in
                            blocker.hideWindow()
                            viewModel.versionApproved()
                        }.store(in: &cancellables)

                    vStack.addArrangedSubview(notNow)
                }

                blocker.window?.addSubview(popupView)
                popupView.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(18)
                    make.center.equalToSuperview()
                    make.right.equalToSuperview().offset(-18)
                }

                blocker.showWindow()

            }.store(in: &cancellables)
    }
}

private final class UpdateBlocker {
    private(set) var window: Window? = Window()

    func showWindow() {
        window?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        window?.rootViewController = StatusBarViewController(nil)
        window?.alpha = 0.0
        window?.makeKeyAndVisible()

        UIView.animate(withDuration: 0.3) { self.window?.alpha = 1.0 }
    }

    func hideWindow() {
        UIView.animate(withDuration: 0.3) {
            self.window?.alpha = 0.0
        } completion: { _ in
            self.window = nil
        }
    }
}
