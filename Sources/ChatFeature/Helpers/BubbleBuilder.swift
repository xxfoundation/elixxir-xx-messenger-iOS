import UIKit
import Shared

final class Bubbler {
    static func build(
        audioBubble: AudioMessageView,
        with item: ChatItem
    ) {
        audioBubble.dateLabel.text = item.date.asHoursAndMinutes()

        switch item.status {
        case .received, .read:
            audioBubble.lockerView.removeFromSuperview()
            audioBubble.backgroundColor = Asset.neutralWhite.color
            audioBubble.dateLabel.textColor = Asset.neutralDisabled.color
            audioBubble.progressLabel.textColor = Asset.neutralDisabled.color
        case .receivingAttachment:
            audioBubble.lockerView.animate()
            audioBubble.backgroundColor = Asset.neutralWhite.color
            audioBubble.dateLabel.textColor = Asset.neutralDisabled.color
            audioBubble.progressLabel.textColor = Asset.neutralDisabled.color
        case .failedToSend:
            audioBubble.lockerView.fail()
            audioBubble.backgroundColor = Asset.accentDanger.color
            audioBubble.dateLabel.textColor = Asset.neutralWhite.color
            audioBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sent:
            audioBubble.lockerView.stop()
            audioBubble.backgroundColor = Asset.brandBubble.color
            audioBubble.dateLabel.textColor = Asset.neutralWhite.color
            audioBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sending, .sendingAttachment:
            audioBubble.lockerView.animate()
            audioBubble.backgroundColor = Asset.brandBubble.color
            audioBubble.dateLabel.textColor = Asset.neutralWhite.color
            audioBubble.progressLabel.textColor = Asset.neutralWhite.color
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
        case .received, .read:
            imageBubble.lockerView.removeFromSuperview()
            imageBubble.backgroundColor = Asset.neutralWhite.color
            imageBubble.dateLabel.textColor = Asset.neutralDisabled.color
            imageBubble.progressLabel.textColor = Asset.neutralDisabled.color
        case .receivingAttachment:
            imageBubble.lockerView.animate()
            imageBubble.backgroundColor = Asset.neutralWhite.color
            imageBubble.dateLabel.textColor = Asset.neutralDisabled.color
            imageBubble.progressLabel.textColor = Asset.neutralDisabled.color
        case .failedToSend:
            imageBubble.lockerView.fail()
            imageBubble.backgroundColor = Asset.accentDanger.color
            imageBubble.dateLabel.textColor = Asset.neutralWhite.color
            imageBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sent:
            imageBubble.lockerView.stop()
            imageBubble.backgroundColor = Asset.brandBubble.color
            imageBubble.dateLabel.textColor = Asset.neutralWhite.color
            imageBubble.progressLabel.textColor = Asset.neutralWhite.color
        case .sending, .sendingAttachment:
            imageBubble.lockerView.animate()
            imageBubble.backgroundColor = Asset.brandBubble.color
            imageBubble.dateLabel.textColor = Asset.neutralWhite.color
            imageBubble.progressLabel.textColor = Asset.neutralWhite.color
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
        case .received, .read, .receivingAttachment:
            bubble.lockerView.removeFromSuperview()
            bubble.backgroundColor = Asset.neutralWhite.color
            bubble.textView.textColor = Asset.neutralActive.color
            bubble.dateLabel.textColor = Asset.neutralDisabled.color
            roundButtonColor = Asset.neutralDisabled.color
            bubble.revertBottomStackOrder()
        case .failedToSend:
            bubble.lockerView.fail()
            bubble.backgroundColor = Asset.accentDanger.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
        case .sent:
            bubble.lockerView.stop()
            bubble.backgroundColor = Asset.brandBubble.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
        case .sending, .sendingAttachment:
            bubble.lockerView.animate()
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
        bubble.roundButton.isHidden = item.roundURL == nil
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
            bubble.lockerView.removeFromSuperview()
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
        bubble.roundButton.isHidden = item.roundURL == nil

        switch item.status {
        case .sent:
            bubble.lockerView.stop()
        case .failed:
            bubble.lockerView.fail()
        case .sending:
            bubble.lockerView.animate()
        case .read, .received:
            bubble.lockerView.removeFromSuperview()
        }
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
        case .received, .read, .receivingAttachment:
            bubble.senderLabel.removeFromSuperview()
            bubble.backgroundColor = Asset.neutralWhite.color
            bubble.textView.textColor = Asset.neutralActive.color
            bubble.dateLabel.textColor = Asset.neutralDisabled.color
            roundButtonColor = Asset.neutralDisabled.color
            bubble.replyView.container.backgroundColor = Asset.brandDefault.color
            bubble.replyView.space.backgroundColor = Asset.brandPrimary.color
            bubble.revertBottomStackOrder()
        case .failedToSend:
            bubble.senderLabel.removeFromSuperview()
            bubble.backgroundColor = Asset.accentDanger.color
            bubble.textView.textColor = Asset.neutralWhite.color
            bubble.dateLabel.textColor = Asset.neutralWhite.color
            roundButtonColor = Asset.neutralWhite.color
            bubble.replyView.space.backgroundColor = Asset.neutralWhite.color
            bubble.replyView.container.backgroundColor = Asset.brandLight.color
        case .sent, .sending, .sendingAttachment:
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
        bubble.roundButton.isHidden = item.roundURL == nil

        switch item.status {
        case .sent:
            bubble.lockerView.stop()
        case .failedToSend:
            bubble.lockerView.fail()
        case .sending, .sendingAttachment:
            bubble.lockerView.animate()
        case .read, .received, .receivingAttachment:
            bubble.lockerView.removeFromSuperview()
        }
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
            bubble.lockerView.removeFromSuperview()
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
        bubble.roundButton.isHidden = item.roundURL == nil

        switch item.status {
        case .failed:
            bubble.lockerView.fail()
        case .sent:
            bubble.lockerView.stop()
        default:
            bubble.lockerView.animate()
        }
    }
}
