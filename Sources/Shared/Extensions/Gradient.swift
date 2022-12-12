import UIKit

public extension CAGradientLayer {
  static func xxGradient() -> CAGradientLayer {
    let gradient = CAGradientLayer()
    gradient.colors = [
      UIColor(red: 122/255, green: 235/255, blue: 239/255, alpha: 1).cgColor,
      UIColor(red: 56/255, green: 204/255, blue: 232/255, alpha: 1).cgColor,
      UIColor(red: 63/255, green: 186/255, blue: 253/255, alpha: 1).cgColor,
      UIColor(red: 98/255, green: 163/255, blue: 255/255, alpha: 1).cgColor
    ]
    gradient.startPoint = CGPoint(x: 0, y: 0)
    gradient.endPoint = CGPoint(x: 1, y: 1)
    return gradient
  }
}
