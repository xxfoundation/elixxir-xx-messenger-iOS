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

    let gradient = CAGradientLayer()
    gradient.colors = [
      UIColor(red: 122/255, green: 235/255, blue: 239/255, alpha: 1).cgColor,
      UIColor(red: 56/255, green: 204/255, blue: 232/255, alpha: 1).cgColor,
      UIColor(red: 63/255, green: 186/255, blue: 253/255, alpha: 1).cgColor,
      UIColor(red: 98/255, green: 163/255, blue: 255/255, alpha: 1).cgColor
    ]

    gradient.startPoint = CGPoint(x: 0, y: 0)
    gradient.endPoint = CGPoint(x: 1, y: 1)
    gradient.frame = screenView.bounds
    screenView.layer.insertSublayer(gradient, at: 0)
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
