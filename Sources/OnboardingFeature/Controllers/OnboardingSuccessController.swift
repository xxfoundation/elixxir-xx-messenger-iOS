import UIKit
import Combine
import AppResources
import Dependencies
import AppNavigation

public final class OnboardingSuccessController: UIViewController {
  @Dependency(\.navigator) var navigator
  @Dependency(\.app.statusBar) var statusBar

  private lazy var screenView = OnboardingSuccessView()

  private let isEmail: Bool
  private var cancellables = Set<AnyCancellable>()

  public init(_ isEmail: Bool) {
    self.isEmail = isEmail
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    screenView.gradientLayer.frame = screenView.bounds
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    statusBar.set(.lightContent)
    navigationController?.navigationBar
      .customize(translucent: true)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    paragraph.lineHeightMultiple = 1.1

    let attrString = NSMutableAttributedString(
      string: isEmail ?
      Localized.Onboarding.Success.Email.title : Localized.Onboarding.Success.Phone.title,
      attributes: [
        .font: Fonts.Mulish.bold.font(size: 39.0),
        .foregroundColor: Asset.neutralWhite.color
      ]
    )

    attrString.addAttribute(
      name: .foregroundColor,
      value: Asset.neutralBody.color,
      betweenCharacters: "#"
    )

    screenView.titleLabel.numberOfLines = 0
    screenView.titleLabel.attributedText = attrString

    screenView.nextButton.set(
      style: .white,
      title: isEmail ?
      Localized.Onboarding.Success.Action.next :
      Localized.Onboarding.Success.Action.done
    )

    screenView
      .nextButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard isEmail == true else {
          navigator.perform(PresentSearch(
            fromOnboarding: true,
            on: navigationController!
          ))
          return
        }
        navigator.perform(
          PresentOnboardingPhone(
            on: navigationController!
          ))
      }.store(in: &cancellables)
  }
}
