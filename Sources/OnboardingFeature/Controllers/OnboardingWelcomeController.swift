import UIKit
import Shared
import Combine
import Defaults
import AppCore
import Dependencies
import AppResources
import AppNavigation
import DrawerFeature

public final class OnboardingWelcomeController: UIViewController {
  @Dependency(\.navigator) var navigator: Navigator
  @Dependency(\.app.statusBar) var statusBar: StatusBarStylist

  @KeyObject(.username, defaultValue: "") var username: String

  private lazy var screenView = OnboardingWelcomeView()

  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()

  public override func loadView() {
    view = screenView
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    statusBar.set(.darkContent)
    navigationController?.navigationBar.customize(translucent: true)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    screenView.setupTitle(
      Localized.Onboarding.Welcome.title(username)
    )
    screenView
      .continueButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        navigator.perform(PresentOnboardingEmail(on: navigationController!))
      }.store(in: &cancellables)

    screenView
      .skipButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        navigator.perform(PresentSearch(
          fromOnboarding: true,
          on: navigationController!
        ))
      }.store(in: &cancellables)

    screenView.didTapInfo = { [weak self] in
      guard let self else { return }
      self.presentInfo(
        title: Localized.Onboarding.Welcome.Info.title,
        subtitle: Localized.Onboarding.Welcome.Info.subtitle,
        urlString: "https://links.xx.network/ud"
      )
    }
  }

  private func presentInfo(
    title: String,
    subtitle: String,
    urlString: String = ""
  ) {
    let actionButton = CapsuleButton()
    actionButton.set(
      style: .seeThrough,
      title: Localized.Settings.InfoDrawer.action
    )
    actionButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) {
          self.drawerCancellables.removeAll()
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: [
      DrawerText(
        font: Fonts.Mulish.bold.font(size: 26.0),
        text: title,
        color: Asset.neutralActive.color,
        alignment: .left,
        spacingAfter: 19
      ),
      DrawerLinkText(
        text: subtitle,
        urlString: urlString,
        spacingAfter: 37
      ),
      DrawerStack(views: [
        actionButton,
        FlexibleSpace()
      ])
    ], isDismissable: true, from: self))
  }
}
