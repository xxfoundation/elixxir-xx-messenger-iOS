import UIKit
import Shared
import AppResources

public final class DrawerLinkText: NSObject, DrawerItem {
  let text: String
  let urlString: String

  public var spacingAfter: CGFloat? = 0

  public init(
    text: String,
    urlString: String,
    spacingAfter: CGFloat = 10
  ) {
    self.text = text
    self.urlString = urlString
    self.spacingAfter = spacingAfter
  }

  public func makeView() -> UIView {
    let textView = UnselectableTextView()
    textView.delegate = self
    textView.isEditable = false
    textView.isSelectable = true
    textView.isScrollEnabled = false
    textView.backgroundColor = .clear
    textView.isUserInteractionEnabled = true

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left
    paragraphStyle.lineHeightMultiple = 1.1

    let attrString = NSMutableAttributedString(string: text)
    attrString.addAttributes([
      .paragraphStyle: paragraphStyle,
      .foregroundColor: Asset.neutralDark.color,
      .font: Fonts.Mulish.regular.font(size: 16.0) as Any
    ])

    if let url = URL(string: urlString) {
      attrString.addAttribute(name: .link, value: url, betweenCharacters: "#")

      textView.linkTextAttributes = [
        .paragraphStyle: paragraphStyle,
        .foregroundColor: Asset.brandPrimary.color,
        .font: Fonts.Mulish.regular.font(size: 16.0) as Any
      ]
    }

    textView.attributedText = attrString

    return textView
  }

  public func textView(
    _: UITextView,
    shouldInteractWith: URL,
    in: NSRange,
    interaction: UITextItemInteraction
  ) -> Bool { true }
}

extension DrawerLinkText: UITextViewDelegate {}
