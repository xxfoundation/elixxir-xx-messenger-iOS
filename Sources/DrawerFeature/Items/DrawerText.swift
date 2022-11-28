import UIKit
import Shared
import AppResources

public final class DrawerText: DrawerItem {
  private let font: UIFont
  private let text: String
  private let color: UIColor
  private let leftImage: UIImage?
  private let alignment: NSTextAlignment
  private let lineHeightMultiple: CGFloat
  private let customAttributes: [NSAttributedString.Key: Any]?
  private let stackView = UIStackView()

  public var spacingAfter: CGFloat? = 0

  public init(
    font: UIFont = Fonts.Mulish.regular.font(size: 16.0),
    text: String,
    color: UIColor = Asset.neutralActive.color,
    alignment: NSTextAlignment = .left,
    lineHeightMultiple: CGFloat = 1.1,
    spacingAfter: CGFloat = 10,
    customAttributes: [NSAttributedString.Key: Any]? = nil,
    leftImage: UIImage? = nil
  ) {
    self.font = font
    self.text = text
    self.color = color
    self.leftImage = leftImage
    self.alignment = alignment
    self.spacingAfter = spacingAfter
    self.customAttributes = customAttributes
    self.lineHeightMultiple = lineHeightMultiple
  }

  public func makeView() -> UIView {
    let label = UILabel()
    label.numberOfLines = 0

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
    paragraphStyle.lineHeightMultiple = lineHeightMultiple

    let attrString = NSMutableAttributedString(string: text)
    attrString.addAttributes([
      .paragraphStyle: paragraphStyle,
      .foregroundColor: color,
      .font: font as Any
    ])

    if let customAttributes = customAttributes {
      attrString.addAttributes(
        attributes: customAttributes,
        betweenCharacters: "#"
      )
    }

    label.attributedText = attrString

    if let image = leftImage {
      let imageView = UIImageView()
      imageView.image = image
      stackView.addArrangedSubview(imageView)
    }

    stackView.addArrangedSubview(label)
    stackView.spacing = 5
    return stackView
  }
}
