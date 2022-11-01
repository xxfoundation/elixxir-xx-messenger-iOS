import UIKit
import Combine

public struct StatusBarStylist {
  public init() {}
  public let styleSubject = CurrentValueSubject<UIStatusBarStyle, Never>(.lightContent)
}
