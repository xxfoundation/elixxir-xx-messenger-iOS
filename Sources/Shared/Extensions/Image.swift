import UIKit

public extension UIImage {
  static func fromBase64(_ base64String: String?) -> UIImage? {
    guard let base64 = base64String,
          let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else { return nil }
    
    return UIImage(data: imageData)
  }
  
  static func color(_ color: UIColor, size: CGSize = .init(width: 1, height: 1)) -> UIImage {
    UIGraphicsImageRenderer(size: size).image { context in
      color.setFill()
      context.fill(CGRect(origin: .zero, size: size))
    }
  }
  
  func orientedUp() -> UIImage {
    if imageOrientation == .up { return self }
    let format = imageRendererFormat
    return UIGraphicsImageRenderer(size: size, format: format).image { _ in draw(at: .zero) }
  }
  
  func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
    let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
    let format = imageRendererFormat
    format.opaque = isOpaque
    return UIGraphicsImageRenderer(size: canvas, format: format).image {
      _ in draw(in: CGRect(origin: .zero, size: canvas))
    }
  }
  
  func compress(to kb: Int) -> Data {
    let bytes = kb * 1024
    var compression: CGFloat = 1.0
    let step: CGFloat = 0.05
    var holderImage = self
    var complete = false
    
    while(!complete) {
      if let data = holderImage.jpegData(compressionQuality: 1.0) {
        let ratio = data.count / bytes
        if data.count < bytes {
          complete = true
          return data
        } else {
          let multiplier: CGFloat = CGFloat((ratio / 5) + 1)
          compression -= (step * multiplier)
        }
      }
      guard let newImage = holderImage.resized(withPercentage: compression) else { break }
      holderImage = newImage
    }
    return Data()
  }
}
