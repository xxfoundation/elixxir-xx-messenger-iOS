import UIKit
import Shared

public final class PopupLabel: PopupStackItem {
    let font: UIFont
    let text: String
    let color: UIColor
    let alignment: NSTextAlignment
    let lineSpacing: CGFloat?
    let lineHeightMultiple: CGFloat?

    public var spacingAfter: CGFloat? = 0

    public init(
        font: UIFont,
        text: String,
        color: UIColor = Asset.neutralDark.color,
        alignment: NSTextAlignment = .center,
        lineSpacing: CGFloat? = nil,
        lineHeightMultiple: CGFloat? = nil,
        spacingAfter: CGFloat = 10
    ) {
        self.font = font
        self.text = text
        self.color = color
        self.alignment = alignment
        self.lineSpacing = lineSpacing
        self.spacingAfter = spacingAfter
        self.lineHeightMultiple = lineHeightMultiple
    }

    public func makeView() -> UIView {
        let label = UILabel()
        label.numberOfLines = 0

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment

        if let spacing = lineSpacing {
            paragraphStyle.lineSpacing = spacing
        }

        if let lineHeightMultiple = lineHeightMultiple {
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
        }

        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font as Any,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]
        )

        return label
    }
}

public final class PopupLinkText: NSObject, PopupStackItem {
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

extension PopupLinkText: UITextViewDelegate {}

public final class UnselectableTextView: UITextView {
    public override var selectedTextRange: UITextRange? {
        get { return nil }
        set {}
    }

    public override func point(
        inside point: CGPoint,
        with event: UIEvent?
    ) -> Bool {
        guard let pos = closestPosition(to: point) else { return false }
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else { return false }

        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
}

public final class PopupLabelAttributed: PopupStackItem {
    let text: String

    public var spacingAfter: CGFloat? = 0

    public init(
        text: String,
        spacingAfter: CGFloat = 10
    ) {
        self.text = text
        self.spacingAfter = spacingAfter
    }

    public func makeView() -> UIView {
        let label = UILabel()
        label.numberOfLines = 0

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineHeightMultiple = 1.1

        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttributes([
            .paragraphStyle: paragraphStyle,
            .foregroundColor: Asset.neutralDark.color,
            .font: Fonts.Mulish.regular.font(size: 16.0) as Any
        ])

        attrString.addAttribute(
            name: .font,
            value: Fonts.Mulish.bold.font(size: 16.0) as Any,
            betweenCharacters: "#"
        )

        label.attributedText = attrString

        return label
    }
}
