import UIKit

public final class TextWithInfoView: UIView {
    private let textView = UITextView()
    public private(set) var didTapInfo: (() -> Void)?

    public init() {
        super.init(frame: .zero)
        textView.backgroundColor = .clear

        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false

        addSubview(textView)
        textView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) { nil }

    public func setup(
        text: String,
        attributes: [NSAttributedString.Key: Any],
        didTapInfo: @escaping () -> Void
    ) {
        let mutable = NSMutableAttributedString(string: "\(text)  ", attributes: attributes)

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = Asset.infoIcon.image

        let imageString = NSAttributedString(attachment: imageAttachment)
        mutable.append(imageString)
        textView.attributedText = mutable

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedTextView(_:)))
        textView.addGestureRecognizer(tapGesture)

        self.didTapInfo = didTapInfo
    }

    @objc private func tappedTextView(_ sender: UITapGestureRecognizer) {
        let textView = sender.view as! UITextView
        let layoutManager = textView.layoutManager

        var location = sender.location(in: textView)
        location.x -= textView.textContainerInset.left;
        location.y -= textView.textContainerInset.top;

        let characterIndex = layoutManager.characterIndex(
            for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil
        )

        if characterIndex < textView.textStorage.length {
            let attributeValue = textView.attributedText.attribute(
                NSAttributedString.Key.attachment, at: characterIndex, effectiveRange: nil
            ) as? NSTextAttachment

            if let _ = attributeValue {
                didTapInfo?()
            }
        }
    }
}
