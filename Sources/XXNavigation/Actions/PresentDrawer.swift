import Navigation
import DrawerFeature

public struct PresentDrawer: Navigation.Action {
  public var items: [DrawerItem]
  public var animated: Bool = true
  public var dismissable: Bool = true

  public init(
    items: [DrawerItem],
    animated: Bool = true,
    dismissable: Bool = true
  ) {
    self.items = items
    self.animated = animated
    self.dismissable = dismissable
  }
}
