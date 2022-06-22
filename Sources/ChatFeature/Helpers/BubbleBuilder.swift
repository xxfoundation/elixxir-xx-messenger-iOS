import UIKit
import Shared

final class Bubbler {
    static func build(
        audioBubble: AudioMessageView,
        with item: ChatItem
    ) {
        audioBubble.dateLabel.text = item.date.asHoursAndMinutes()

        switch item.status {
        case .received:
            audioBubble.lockerImageView.removeFromSuperview()
            audioBubble.backgroundColor = Asset.neutralWhite.color
            audioBubble.dateLabel.textColor = Asset.neutralDisabled.color
            audioBubble.progressLabel.textColor = Asset.neutralDisabled.color
        case .receiving:
            audioBubble.backgroundColor = Asset.neutralWhite.color
            audioBubble.dateLabel.textColor = Asset.neutralDisabled.color
            audioBubble.progressLabel.textColor = Asset.neutralDisabled.color
        case .sendingTimedOut:
            audioBubble.backgroundColor = Asset.accentWarning.color
            audioBubble.dateLabel.textColor = Asset.neutralWhite.color
            audioBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sendingFailed:
            audioBubble.backgroundColor = Asset.accentDanger.color
            audioBubble.dateLabel.textColor = Asset.neutralWhite.color
            audioBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sent:
            audioBubble.backgroundColor = Asset.brandBubble.color
            audioBubble.dateLabel.textColor = Asset.neutralWhite.color
            audioBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sending:
            audioBubble.backgroundColor = Asset.brandBubble.color
            audioBubble.dateLabel.textColor = Asset.neutralWhite.color
            audioBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .receivingFailed:
            fatalError()
        }
    }

    static func build(
        imageBubble: ImageMessageView,
        with item: ChatItem
    ) {
        let progress = item.payload.attachment!.progress
        imageBubble.progressLabel.text = String(format: "%.1f%%", progress * 100)
        imageBubble.dateLabel.text = item.date.asHoursAndMinutes()

        switch item.status {
        case .received:
            imageBubble.lockerImageView.removeFromSuperview()
            imageBubble.backgroundColor = Asset.neutralWhite.color
            imageBubble.dateLabel.textColor = Asset.neutralDisabled.color
            imageBubble.progressLabel.textColor = Asset.neutralDisabled.color
        case .receiving:
            imageBubble.backgroundColor = Asset.neutralWhite.color
            imageBubble.dateLabel.textColor = Asset.neutralDisabled.color
            imageBubble.progressLabel.textColor = Asset.neutralDisabled.color
        case .sendingFailed:
            imageBubble.backgroundColor = Asset.accentDanger.color
            imageBubble.dateLabel.textColor = Asset.neutralWhite.color
            imageBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sendingTimedOut:
            imageBubble.backgroundColor = Asset.accentWarning.color
            imageBubble.dateLabel.textColor = Asset.neutralWhite.color
            imageBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sent:
            imageBubble.backgroundColor = Asset.brandBubble.color
            imageBubble.dateLabel.textColor = Asset.neutralWhite.color
            imageBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sending:
            imageBubble.backgroundColor = Asset.brandBubble.color
            imageBubble.dateLabel.textColor = Asset.neutralWhite.color
            imageBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .receivingFailed:
            fatalError()
        }
    }

    static func build(
        bubble: StackMessageView,
        with item: ChatItem
    ) {
        bubble.textView.text = item.payload.text
        bubble.senderLabel.removeFromSuperview()
        bubble.dateLabel.text = item.date.asHoursAndMinutes()

        let roundButtonColor: UIColor

        switch item.status {
        case .received, .receiving:
            bubble.lockerImageView.removeFromSuperview()
            bubble.backgroundColor = Asset.neutralWhite.color
            bubble.textView.textColor = Asset.neutralActive.color
            bubble.dateLabel.textColor = Asset.neutralDisabled.color
            roundButtonColor = Asset.neutralDisabled.color
            bubble.revertBottomStackOrder()
        case .sendingTimedOut:
            bubble.backgroundColor = Asset.accentWarning.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
        case .sendingFailed:
            bubble.backgroundColor = Asset.accentDanger.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
        case .sent:
            bubble.backgroundColor = Asset.brandBubble.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
        case .sending:
            bubble.backgroundColor = Asset.brandBubble.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
        case .receivingFailed:
            fatalError()
        }

        let attrString = NSAttributedString(
            string: "show mix",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: roundButtonColor,
                .foregroundColor: roundButtonColor,
                .font: Fonts.Mulish.regular.font(size: 12.0) as Any
            ]
        )

        bubble.roundButton.setAttributedTitle(attrString, for: .normal)
    }

    static func buildGroup(
        bubble: StackMessageView,
        with item: GroupChatItem,
        with senderName: String
    ) {
        bubble.textView.text = item.payload.text
        bubble.dateLabel.text = item.date.asHoursAndMinutes()

        let roundButtonColor: UIColor

        switch item.status {
        case .received, .read:
            bubble.senderLabel.text = senderName
            bubble.backgroundColor = Asset.neutralWhite.color
            bubble.textView.textColor = Asset.neutralActive.color
            bubble.dateLabel.textColor = Asset.neutralDisabled.color
            roundButtonColor = Asset.neutralDisabled.color
            bubble.lockerImageView.removeFromSuperview()
            bubble.revertBottomStackOrder()
        case .failed:
            bubble.senderLabel.removeFromSuperview()
            bubble.backgroundColor = Asset.accentDanger.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
        case .sent, .sending:
            bubble.senderLabel.removeFromSuperview()
            bubble.backgroundColor = Asset.brandBubble.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
        }

        let attrString = NSAttributedString(
            string: "show mix",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: roundButtonColor,
                .foregroundColor: roundButtonColor,
                .font: Fonts.Mulish.regular.font(size: 12.0) as Any
            ]
        )

        bubble.roundButton.setAttributedTitle(attrString, for: .normal)
    }

    static func buildReply(
        bubble: ReplyStackMessageView,
        with item: ChatItem,
        reply: ReplyModel
    ) {
        bubble.dateLabel.text = item.date.asHoursAndMinutes()
        bubble.textView.text = item.payload.text

        bubble.replyView.message.text = reply.text
        bubble.replyView.title.text = reply.sender

        let roundButtonColor: UIColor

        switch item.status {
        case .received, .receiving:
            bubble.senderLabel.removeFromSuperview()
            bubble.backgroundColor = Asset.neutralWhite.color
            bubble.textView.textColor = Asset.neutralActive.color
            bubble.dateLabel.textColor = Asset.neutralDisabled.color
            roundButtonColor = Asset.neutralDisabled.color
            bubble.replyView.container.backgroundColor = Asset.brandDefault.color
            bubble.replyView.space.backgroundColor = Asset.brandPrimary.color
            bubble.revertBottomStackOrder()
        case .sendingTimedOut:
            bubble.senderLabel.removeFromSuperview()
            bubble.backgroundColor = Asset.accentWarning.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
            bubble.replyView.space.backgroundColor = Asset.neutralWhite.color
            bubble.replyView.container.backgroundColor = Asset.brandLight.color
        case .sendingFailed:
            bubble.senderLabel.removeFromSuperview()
            bubble.backgroundColor = Asset.accentDanger.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
            bubble.replyView.space.backgroundColor = Asset.neutralWhite.color
            bubble.replyView.container.backgroundColor = Asset.brandLight.color
        case .sent, .sending:
            bubble.senderLabel.removeFromSuperview()
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.backgroundColor = Asset.brandBubble.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
            bubble.replyView.space.backgroundColor = Asset.neutralWhite.color
            bubble.replyView.container.backgroundColor = Asset.brandLight.color
        case .receivingFailed:
            fatalError()
        }

        let attrString = NSAttributedString(
            string: "show mix",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: roundButtonColor,
                .foregroundColor: roundButtonColor,
                .font: Fonts.Mulish.regular.font(size: 12.0) as Any
            ]
        )
        bubble.roundButton.setAttributedTitle(attrString, for: .normal)
    }

    static func buildReplyGroup(
        bubble: ReplyStackMessageView,
        with item: GroupChatItem,
        reply: ReplyModel,
        sender: String
    ) {
        bubble.dateLabel.text = item.date.asHoursAndMinutes()
        bubble.textView.text = item.payload.text

        bubble.replyView.message.text = reply.text
        bubble.replyView.title.text = reply.sender

        let roundButtonColor: UIColor

        switch item.status {
        case .received, .read:
            bubble.senderLabel.text = sender
            bubble.backgroundColor = Asset.neutralWhite.color
            bubble.textView.textColor = Asset.neutralActive.color
            bubble.dateLabel.textColor = Asset.neutralDisabled.color
            roundButtonColor = Asset.neutralDisabled.color
            bubble.replyView.container.backgroundColor = Asset.brandDefault.color
            bubble.replyView.space.backgroundColor = Asset.brandPrimary.color
            bubble.lockerImageView.removeFromSuperview()
            bubble.revertBottomStackOrder()
        case .failed:
            bubble.senderLabel.removeFromSuperview()
            bubble.backgroundColor = Asset.accentDanger.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
            bubble.replyView.space.backgroundColor = Asset.neutralWhite.color
            bubble.replyView.container.backgroundColor = Asset.brandLight.color
        case .sent, .sending:
            bubble.senderLabel.removeFromSuperview()
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.backgroundColor = Asset.brandBubble.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
            bubble.replyView.space.backgroundColor = Asset.neutralWhite.color
            bubble.replyView.container.backgroundColor = Asset.brandLight.color
        }

        let attrString = NSAttributedString(
            string: "show mix",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: roundButtonColor,
                .foregroundColor: roundButtonColor,
                .font: Fonts.Mulish.regular.font(size: 12.0) as Any
            ]
        )

        bubble.roundButton.setAttributedTitle(attrString, for: .normal)
    }
}
