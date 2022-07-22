import HUD
import UIKit
import Models
import Shared
import Combine
import Countries
import DependencyInjection
import ScrollViewController

public typealias ControllerClosure = (UIViewController, AttributeConfirmation) -> Void

public final class ProfileCodeController: UIViewController {
    @Dependency private var hud: HUD

    lazy private var screenView = ProfileCodeView()
    lazy private var scrollViewController = ScrollViewController()

    private let completion: ControllerClosure
    private let confirmation: AttributeConfirmation
    private var cancellables = Set<AnyCancellable>()
    lazy private var viewModel = ProfileCodeViewModel(confirmation)

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .customize(backgroundColor: Asset.neutralWhite.color)
    }

    public init(
        _ confirmation: AttributeConfirmation,
        _ completion: @escaping ControllerClosure
    ) {
        self.completion = completion
        self.confirmation = confirmation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupScrollView()
        setupBindings()
        setupDetail()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = " "

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

        screenView.inputField.textPublisher
            .sink { [unowned self] in viewModel.didInput($0) }
            .store(in: &cancellables)

        viewModel.state
            .map(\.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                switch $0 {
                case .valid:
                    screenView.saveButton.isEnabled = true
                case .invalid, .unknown:
                    screenView.saveButton.isEnabled = false
                }
            }.store(in: &cancellables)

        screenView.saveButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in viewModel.didTapNext() }
            .store(in: &cancellables)

        viewModel.state
            .map(\.resendDebouncer)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                screenView.resendButton.isEnabled = $0 == 0

                if $0 == 0 {
                    screenView.resendButton.setTitle(Localized.Profile.Code.resend(""), for: .normal)
                } else {
                    screenView.resendButton.setTitle(Localized.Profile.Code.resend("(\($0))"), for: .disabled)
                }
            }.store(in: &cancellables)

        screenView.resendButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in viewModel.didTapResend() }
            .store(in: &cancellables)

        viewModel.completionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in completion(self, $0) }
            .store(in: &cancellables)
    }

    private func setupDetail() {
        var content: String!

        if confirmation.isEmail {
            content = confirmation.content
        } else {
            let country = Country.findFrom(confirmation.content)
            content = "\(country.prefix)\(confirmation.content.dropLast(2))"
        }

        screenView.set(content, isEmail: confirmation.isEmail)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
