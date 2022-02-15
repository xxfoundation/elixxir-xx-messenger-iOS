import UIKit
import ChatLayout

extension ChatLayout {
    func configure(_ layoutDelegate: ChatLayoutDelegate) {
        delegate = layoutDelegate
        settings.estimatedItemSize = CGSize(width: 100, height: 65)
        settings.interItemSpacing = 8
        settings.interSectionSpacing = 8
        keepContentOffsetAtBottomOnBatchUpdates = true
        settings.additionalInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    }
}

final class LayoutDelegate: ChatLayoutDelegate {
    public func alignmentForItem(_: ChatLayout, of kind: ItemKind, at: IndexPath) -> ChatItemAlignment {
        .fullWidth
    }

    public func shouldPresentHeader(_ chatLayout: ChatLayout, at sectionIndex: Int) -> Bool {
        true
    }
}
