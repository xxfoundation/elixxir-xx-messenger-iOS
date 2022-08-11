import UIKit
import Theme
import Shared
import Combine
import Defaults
import DependencyInjection

public final class TermsConditionsController: UIViewController {
    @Dependency var coordinator: TermsCoordinator
    @Dependency var statusBarController: StatusBarStyleControlling

    @KeyObject(.acceptedTerms, defaultValue: false) var didAcceptTerms: Bool

    lazy private var screenView = TermsConditionsView()

    private let ndf: String?
    private var cancellables = Set<AnyCancellable>()

    public init(_ ndf: String?) {
        self.ndf = ndf
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func loadView() {
        view = screenView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar.customize(translucent: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = ""

        let backButton = UIButton()
        backButton.setImage(Asset.navigationBarBack.image, for: .normal)
        backButton.tintColor = Asset.neutralActive.color
        backButton.imageView?.contentMode = .center
        backButton.snp.makeConstraints { $0.width.equalTo(50) }
        backButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                navigationController?.popViewController(animated: true)
            }.store(in: &cancellables)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [backButton])
        )

        screenView.radioComponent
            .radioButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                screenView.radioComponent.isEnabled.toggle()
                screenView.nextButton.isEnabled = screenView.radioComponent.isEnabled
            }.store(in: &cancellables)

        screenView.nextButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                didAcceptTerms = true

                if let ndf = ndf {
                    coordinator.presentUsername(ndf, self)
                } else {
                    coordinator.presentChatList(self)
                }
            }.store(in: &cancellables)

        screenView.showTermsButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // TODO
            }.store(in: &cancellables)
    }
}
