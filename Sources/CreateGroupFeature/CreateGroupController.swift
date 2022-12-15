import UIKit
import Shared
import Combine
import XXModels
import Dependencies
import AppResources
import AppNavigation
import DrawerFeature

public final class CreateGroupController: UIViewController {
  @Dependency(\.navigator) var navigator

  private lazy var screenView = CreateGroupView()

  private let groupMembers: [Contact]
  private let viewModel = CreateGroupViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()

  public init(_ groupMembers: [Contact]) {
    self.groupMembers = groupMembers
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    screenView.set(count: groupMembers.count, didTap: { [weak self] in
      guard let self else { return }

      let actionButton = CapsuleButton()
      actionButton.setStyle(.seeThrough)
      actionButton.setTitle(Localized.CreateGroup.Drawer.gotit, for: .normal)

      actionButton
        .publisher(for: .touchUpInside)
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in
          self.navigator.perform(DismissModal(from: self)) { [weak self] in
            guard let self else { return }
            self.drawerCancellables.removeAll()
          }
        }.store(in: &self.drawerCancellables)

      self.navigator.perform(PresentDrawer(items: [
        DrawerText(
          font: Fonts.Mulish.bold.font(size: 26.0),
          text: Localized.CreateGroup.Drawer.title,
          color: Asset.neutralActive.color,
          alignment: .left,
          spacingAfter: 19
        ),
        DrawerText(
          font: Fonts.Mulish.regular.font(size: 16.0),
          text: Localized.CreateGroup.Drawer.otherSubtitle,
          color: Asset.neutralDark.color,
          alignment: .left,
          spacingAfter: 20
        ),
        DrawerStack(views: [
          actionButton,
          FlexibleSpace()
        ])
      ], isDismissable: true, from: self))
    })

    viewModel
      .statePublisher
      .map(\.status)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.update(status: $0)
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.shouldDismiss)
      .filter { $0 == true }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        dismiss(animated: true)
      }.store(in: &cancellables)

    screenView
      .cancelButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true)
      }.store(in: &cancellables)

    screenView
      .inputField
      .textPublisher
      .sink { [unowned self] in
        viewModel.didInput($0)
      }.store(in: &cancellables)

    screenView
      .otherInputField
      .textPublisher
      .sink { [unowned self] in
        viewModel.didOtherInput($0)
      }.store(in: &cancellables)

    screenView
      .inputField
      .returnPublisher
      .sink { [unowned self] in
        screenView.inputField.endEditing(true)
      }.store(in: &cancellables)

    screenView
      .otherInputField
      .returnPublisher
      .sink { [unowned self] in
        screenView.otherInputField.endEditing(true)
      }.store(in: &cancellables)

    screenView
      .createButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        viewModel.didTapCreate(groupMembers)
      }.store(in: &cancellables)
  }
}
