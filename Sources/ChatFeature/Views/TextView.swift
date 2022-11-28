import UIKit
import Shared
import AppResources

/// UITextView avoiding selection

final class TextView: UITextView {
    // MARK: Properties

    override var isFocused: Bool { false }
    override var canBecomeFirstResponder: Bool { false }
    override var canBecomeFocused: Bool { false }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool { false }

    // MARK: Lifecycle

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        bounces = false
        isEditable = false
        bouncesZoom = false
        scrollsToTop = false
        isScrollEnabled = false
        isExclusiveTouch = true
        spellCheckingType = .no
        dataDetectorTypes = .all
        backgroundColor = .clear
        textContainerInset = .zero
        showsVerticalScrollIndicator = false
        font = Fonts.Mulish.regular.font(size: 16.0)
        textContainer.lineFragmentPadding = 0
        showsHorizontalScrollIndicator = false
        layoutManager.allowsNonContiguousLayout = true
    }
}
