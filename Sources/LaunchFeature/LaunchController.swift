import UIKit
import Shared
import Combine
import Navigation
import PushFeature
import DrawerFeature
import AppResources
import ComposableArchitecture

public final class LaunchController: UIViewController {
  @Dependency(\.navigator) var navigator: Navigator

  private lazy var screenView = LaunchView()

  private let viewModel = LaunchViewModel()
  public var pendingPushRoute: PushRouter.Route?
  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.viewDidAppear()
  }

  public override func loadView() {
    view = screenView
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
    gradient.frame = screenView.bounds
    gradient.startPoint = CGPoint(x: 1, y: 0)
    gradient.endPoint = CGPoint(x: 0, y: 1)
    screenView.layer.insertSublayer(gradient, at: 0)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    viewModel
      .statePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard $0.shouldPushChats == false else {
          guard $0.shouldShowTerms == false else {
            navigator.perform(PresentTermsAndConditions(replacing: true, on: navigationController!))
            return
          }
          if let route = pendingPushRoute {
            hasPendingPushRoute(route)
            return
          }
          navigator.perform(PresentChatList(on: navigationController!))
          return
        }
        guard $0.shouldPushOnboarding == false else {
          navigator.perform(PresentOnboardingStart(on: navigationController!))
          return
        }
        if let update = $0.shouldOfferUpdate {
          offerUpdate(model: update)
        }
      }.store(in: &cancellables)
  }

  private func hasPendingPushRoute(_ route: PushRouter.Route) {
    switch route {
    case .requests:
      navigator.perform(PresentRequests(on: navigationController!))
    case .search(username: let username):
      navigator.perform(PresentSearch(
        searching: username,
        replacing: true,
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
