import XXModels
import Navigation

public struct PresentChat: Navigation.Action {
  public var contact: Contact
  public var animated: Bool = true

  public init(contact: Contact, animated: Bool = true) {
    self.contact = contact
    self.animated = animated
  }
}
