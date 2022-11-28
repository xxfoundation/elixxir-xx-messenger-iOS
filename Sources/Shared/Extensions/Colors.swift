import UIKit

public extension UIColor {
  static func fade(from color: UIColor, to: UIColor, pcent: CGFloat) -> UIColor {
    var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
    color.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
    
    var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
    to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
    
    let red = (toRed - fromRed) * pcent + fromRed
    let green = (toGreen - fromGreen) * pcent + fromGreen
    let blue = (toBlue - fromBlue) * pcent + fromBlue
    let alpha = (toAlpha - fromAlpha) * pcent + fromAlpha
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}
