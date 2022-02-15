import UIKit
import Shared

final class TextInputView: UIView, UITextViewDelegate {
    let internalStack = UIStackView()
    var replyView = ChatInputReply()
    var placeholderView = UITextView()
    lazy var bubble = BubbleView(internalStack, padding: 4)

    let stack = UIStackView()
    let textView = UITextView()
    let showActionsButton = UIButton()
    let hideActionsButton = UIButton()
    let sendButton = UIButton()
    let audioButton = UIButton()

    var maxHeight: () -> CGFloat = { 150 }
    var textDidChange: (String) -> Void = { _ in }

    private var computedTextHeight: CGFloat {
        let textWidth = textView.frame.size.width
        let size = CGSize(width: textWidth, height: .greatestFiniteMagnitude)
        return textView.sizeThatFits(size).height
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeight()
    }

    func updateHeight() {
        let replyHeight = replyView.isHidden ? 0 : replyView.bounds.height
        let computedTextHeight = self.computedTextHeight
        let computedHeight = computedTextHeight + replyHeight
        let maxHeight = self.maxHeight()

        if computedHeight < maxHeight {
            textView.snp.updateConstraints { $0.height.equalTo(computedTextHeight) }
            textView.isScrollEnabled = false
        } else {
            textView.snp.updateConstraints { $0.height.equalTo(maxHeight - replyHeight) }
            textView.isScrollEnabled = true
        }
    }

    private func setup() {
        replyView.isHidden = true
        textView.autocorrectionType = .default
        placeholderView.isUserInteractionEnabled = false
        textView.font = Fonts.Mulish.semiBold.font(size: 14.0)
        placeholderView.text = Localized.Chat.placeholder
        placeholderView.font = Fonts.Mulish.semiBold.font(size: 14.0)

        textView.backgroundColor = .clear
        placeholderView.backgroundColor = .clear
        textView.textColor = Asset.neutralActive.color
        bubble.backgroundColor = Asset.neutralSecondary.color
        placeholderView.textColor = Asset.neutralDisabled.color

        showActionsButton.setImage(Asset.chatInputActionOpen.image, for: .normal)
        hideActionsButton.setImage(Asset.chatInputActionClose.image, for: .normal)
        audioButton.setImage(Asset.chatInputVoiceStart.image, for: .normal)
        sendButton.setImage(Asset.chatSend.image, for: .normal)

        showActionsButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        showActionsButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        hideActionsButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        hideActionsButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        sendButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        sendButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        audioButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        audioButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        internalStack.axis = .vertical
        internalStack.addArrangedSubview(replyView)
        internalStack.addArrangedSubview(textView)

        textView.addSubview(placeholderView)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        placeholderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }

        stack.axis = .horizontal
        stack.spacing = 8
        stack.addArrangedSubview(showActionsButton)
        stack.addArrangedSubview(hideActionsButton)
        stack.addArrangedSubview(bubble)
        stack.addArrangedSubview(sendButton)
        stack.addArrangedSubview(audioButton)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        textView.delegate = self
    }

    func textViewDidChange(_ textView: UITextView) {
        textDidChange(textView.text)
    }
}
