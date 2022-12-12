import UIKit
import Shared
import Combine
import Dependencies
import AppResources
import DrawerFeature
import AppNavigation

public final class LaunchController: UIViewController {
  @Dependency(\.navigator) var navigator

  private lazy var screenView = LaunchView()
  private let viewModel = LaunchViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()

  public var pendingPushNotificationRoute: PushNotificationRouter.Route?

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    screenView.gradientLayer.frame = screenView.bounds
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    viewModel
      .statePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard $0.shouldPushEndDestination != .some(.chats) else {
          guard $0.shouldShowTerms == false else {
            navigator.perform(PresentTermsAndConditions(replacing: true, on: navigationController!))
            return
          }
          if let route = pendingPushNotificationRoute {
            hasPendingPushRoute(route)
            return
          }
          navigator.perform(PresentChatList(on: navigationController!))
          return
        }
        guard $0.shouldPushEndDestination != .some(.onboarding) else {
          navigator.perform(PresentOnboardingStart(on: navigationController!))
          return
        }
        if let update = $0.shouldOfferUpdate {
          offerUpdate(model: update)
        }
      }.store(in: &cancellables)

    viewModel.startLaunch()
  }

  private func hasPendingPushRoute(_ route: PushNotificationRouter.Route) {
    switch route {
    case .requests:
      navigator.perform(PresentRequests(on: navigationController!))
    case .search(username: let username):
      navigator.perform(PresentSearch(
        searching: username,
        fromOnboarding: true,
        on: navigationController!))
    case .groupChat(id: let groupId):
      if let info = viewModel.getGroupInfoWith(groupId: groupId) {
        navigator.perform(PresentGroupChat(groupInfo: info, on: navigationController!))
        return
      }
      navigator.perform(PresentChatList(on: navigationController!))
    case .contactChat(id: let userId):
      if let model = viewModel.getContactWith(userId: userId) {
        navigator.perform(PresentChat(contact: model, on: navigationController!))
        return
      }
      navigator.perform(PresentChatList(on: navigationController!))
    }
  }

  private func offerUpdate(model: LaunchViewModel.UpdateModel) {
    let updateButton = CapsuleButton()
    updateButton.set(
      style: .brandColored,
      title: model.positiveActionTitle
    )
    let notNowButton = CapsuleButton()
    if let negativeTitle = model.negativeActionTitle {
      notNowButton.set(
        style: .red,
        title: negativeTitle
      )
    }
    updateButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) {
          self.drawerCancellables.removeAll()
          UIApplication.shared.open(.init(string: model.urlString)!)
        }
      }.store(in: &drawerCancellables)

    notNowButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) {
          self.drawerCancellables.removeAll()
          self.viewModel.didRefuseUpdating()
        }
      }.store(in: &drawerCancellables)

    var actions: [UIView] = [updateButton]
    if model.negativeActionTitle != nil {
      actions.append(notNowButton)
    }

    navigator.perform(PresentDrawer(items: [
      DrawerText(
        font: Fonts.Mulish.bold.font(size: 26.0),
        text: "App Update",
        color: Asset.neutralActive.color,
        alignment: .center,
        spacingAfter: 19
      ),
      DrawerText(
        font: Fonts.Mulish.regular.font(size: 16.0),
        text: model.content,
        color: Asset.neutralBody.color,
        alignment: .center,
        spacingAfter: 19
      ),
      DrawerStack(
        axis: .vertical,
        views: actions
      )
    ], isDismissable: false, from: self))
  }
}
