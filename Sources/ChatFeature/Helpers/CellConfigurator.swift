import UIKit
import Shared
import Combine
import Voxophone
import AVFoundation

struct CellFactory {
    var canBuild: (ChatItem) -> Bool

    var build: (ChatItem, UICollectionView, IndexPath) -> UICollectionViewCell

    func callAsFunction(
        item: ChatItem,
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        build(item, collectionView, indexPath)
    }
}

extension CellFactory {
    static func combined(factories: [CellFactory]) -> Self {
        .init(
            canBuild: { _ in true },
            build: { item, collectionView, indexPath in
                guard let factory = factories.first(where: { $0.canBuild(item)}) else {
                    fatalError("Couldn't find a factory for \(item). Did you forget to implement?")
                }

                return factory(
                    item: item,
                    collectionView: collectionView,
                    indexPath: indexPath
                )
            }
        )
    }
}

extension CellFactory {
    static func incomingAudio(
        voxophone: Voxophone
    ) -> Self {
        .init(
            canBuild: { item in
                (item.status == .received || item.status == .read || item.status == .receivingAttachment)
                && item.payload.reply == nil
                && item.payload.attachment != nil
                && item.payload.attachment?._extension == .audio

            }, build: { item, collectionView, indexPath in
                guard let attachment = item.payload.attachment else { fatalError() }

                let cell: IncomingAudioCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                let url = FileManager.url(for: "\(attachment.name).\(attachment._extension.written)")!

                var model = AudioMessageCellState(
                    date: item.date,
                    audioURL: url,
                    isPlaying: false,
                    transferProgress: attachment.progress,
                    isLoudspeaker: false,
                    duration: (try? AVAudioPlayer(contentsOf: url).duration) ?? 0.0,
                    playbackTime: 0.0
                )

                cell.leftView.setup(with: model)
                cell.canReply = item.status.canReply
                cell.performReply = {}

                Bubbler.build(audioBubble: cell.leftView, with: item)

                voxophone.$state
                    .sink {
                        switch $0 {
                        case .playing(url, _, time: let time, _):
                            model.isPlaying = true
                            model.playbackTime = time
                        default:
                            model.isPlaying = false
                            model.playbackTime = 0.0
                        }

                        model.isLoudspeaker = $0.isLoudspeaker

                        cell.leftView.setup(with: model)
                    }.store(in: &cell.leftView.cancellables)

                cell.leftView.didTapRight = {
                    guard item.status != .receivingAttachment else { return }

                    voxophone.toggleLoudspeaker()
                }

                cell.leftView.didTapLeft = {
                    guard item.status != .receivingAttachment else { return }

                    if case .playing(url, _, _, _) = voxophone.state {
                        voxophone.reset()
                    } else {
                        voxophone.load(url)
                        voxophone.play()
                    }
                }

                return cell
            }
        )
    }

    static func outgoingAudio(
        voxophone: Voxophone
    ) -> Self {
        .init(
            canBuild: { item in
                (item.status == .sent ||
                 item.status == .failedToSend ||
                 item.status == .sendingAttachment ||
                 item.status == .timedOut)
                && item.payload.reply == nil
                && item.payload.attachment != nil
                && item.payload.attachment?._extension == .audio

            }, build: { item, collectionView, indexPath in
                guard let attachment = item.payload.attachment else { fatalError() }

                let cell: OutgoingAudioCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                let url = FileManager.url(for: "\(attachment.name).\(attachment._extension.written)")!
                var model = AudioMessageCellState(
                    date: item.date,
                    audioURL: url,
                    isPlaying: false,
                    transferProgress: attachment.progress,
                    isLoudspeaker: false,
                    duration: (try? AVAudioPlayer(contentsOf: url).duration) ?? 0.0,
                    playbackTime: 0.0
                )

                cell.rightView.setup(with: model)
                cell.canReply = item.status.canReply
                cell.performReply = {}

                Bubbler.build(audioBubble: cell.rightView, with: item)

                voxophone.$state
                    .sink {
                        switch $0 {
                        case .playing(url, _, time: let time, _):
                            model.isPlaying = true
                            model.playbackTime = time
                        default:
                            model.isPlaying = false
                            model.playbackTime = 0.0
                        }

                        model.isLoudspeaker = $0.isLoudspeaker

                        cell.rightView.setup(with: model)
                    }.store(in: &cell.rightView.cancellables)

                cell.rightView.didTapRight = {
                    voxophone.toggleLoudspeaker()
                }

                cell.rightView.didTapLeft = {
                    if case .playing(url, _, _, _) = voxophone.state {
                        voxophone.reset()
                    } else {
                        voxophone.load(url)
                        voxophone.play()
                    }
                }

                return cell
            }
        )
    }
}

extension CellFactory {
    static func outgoingImage() -> Self {
        .init(
            canBuild: { item in
                (item.status == .sent ||
                 item.status == .failedToSend ||
                 item.status == .sendingAttachment ||
                 item.status == .timedOut)
                && item.payload.reply == nil
                && item.payload.attachment != nil
                && item.payload.attachment?._extension == .image

            }, build: { item, collectionView, indexPath in
                guard let attachment = item.payload.attachment else { fatalError() }

                let cell: OutgoingImageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.build(imageBubble: cell.rightView, with: item)

                cell.canReply = item.status.canReply
                cell.performReply = {}

                if let image = UIImage(data: attachment.data!) {
                    cell.rightView.imageView.image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .up)
                }

                return cell
            }
        )
    }

    static func incomingImage() -> Self {
        .init(
            canBuild: { item in
                (item.status == .received || item.status == .read || item.status == .receivingAttachment)
                && item.payload.reply == nil
                && item.payload.attachment != nil
                && item.payload.attachment?._extension == .image

            }, build: { item, collectionView, indexPath in
                guard let attachment = item.payload.attachment else { fatalError() }

                let cell: IncomingImageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.build(imageBubble: cell.leftView, with: item)
                cell.canReply = item.status.canReply
                cell.performReply = {}
                cell.leftView.imageView.image = UIImage(data: attachment.data!)
                return cell
            }
        )
    }
}

extension CellFactory {
    static func outgoingReply(
        performReply: @escaping () -> Void,
        name: @escaping (Data) -> String,
        text: @escaping (Data) -> String,
        showRound: @escaping (String?) -> Void
    ) -> Self {
        .init(
            canBuild: { item in
                (item.status == .sent || item.status == .sending)
                && item.payload.reply != nil
                && item.payload.attachment == nil

            }, build: { item, collectionView, indexPath in
                let cell: OutgoingReplyCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.buildReply(
                    bubble: cell.rightView,
                    with: item,
                    reply: .init(
                        text: text(item.payload.reply!.messageId),
                        sender: name(item.payload.reply!.senderId)
                    )
                )

                cell.canReply = item.status.canReply
                cell.performReply = performReply
                cell.rightView.roundButton.isHidden = item.roundURL == nil
                cell.rightView.didTapShowRound = { showRound(item.roundURL) }
                return cell
            }
        )
    }

    static func incomingReply(
        performReply: @escaping () -> Void,
        name: @escaping (Data) -> String,
        text: @escaping (Data) -> String,
        showRound: @escaping (String?) -> Void
    ) -> Self {
        .init(
            canBuild: { item in
                (item.status == .received || item.status == .read)
                && item.payload.reply != nil
                && item.payload.attachment == nil

            }, build: { item, collectionView, indexPath in
                let cell: IncomingReplyCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.buildReply(
                    bubble: cell.leftView,
                    with: item,
                    reply: .init(
                        text: text(item.payload.reply!.messageId),
                        sender: name(item.payload.reply!.senderId)
                    )
                )
                cell.canReply = item.status.canReply
                cell.performReply = performReply
                cell.leftView.roundButton.isHidden = item.roundURL == nil
                cell.leftView.didTapShowRound = { showRound(item.roundURL) }
                cell.leftView.revertBottomStackOrder()
                return cell
            }
        )
    }

    static func outgoingFailedReply(
        performReply: @escaping () -> Void,
        name: @escaping (Data) -> String,
        text: @escaping (Data) -> String
    ) -> Self {
        .init(
            canBuild: { item in
                (item.status == .failedToSend || item.status == .timedOut)
                && item.payload.reply != nil
                && item.payload.attachment == nil

            }, build: { item, collectionView, indexPath in
                let cell: OutgoingFailedReplyCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.buildReply(
                    bubble: cell.rightView,
                    with: item,
                    reply: .init(
                        text: text(item.payload.reply!.messageId),
                        sender: name(item.payload.reply!.senderId)
                    )
                )

                cell.canReply = item.status.canReply
                cell.performReply = performReply
                return cell
            }
        )
    }
}

extension CellFactory {
    static func incomingText(
        performReply: @escaping () -> Void,
        showRound: @escaping (String?) -> Void
    ) -> Self {
        .init(
            canBuild: { item in
                (item.status == .received || item.status == .read)
                && item.payload.reply == nil
                && item.payload.attachment == nil

            }, build: { item, collectionView, indexPath in
                let cell: IncomingTextCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.build(bubble: cell.leftView, with: item)
                cell.canReply = item.status.canReply
                cell.performReply = performReply
                cell.leftView.roundButton.isHidden = item.roundURL == nil
                cell.leftView.didTapShowRound = { showRound(item.roundURL) }
                cell.leftView.revertBottomStackOrder()
                return cell
            }
        )
    }

    static func outgoingText(
        performReply: @escaping () -> Void,
        showRound: @escaping (String?) -> Void
    ) -> Self {
        .init(
            canBuild: { item in
                (item.status == .sending || item.status == .sent)
                && item.payload.reply == nil
                && item.payload.attachment == nil

            }, build: { item, collectionView, indexPath in
                let cell: OutgoingTextCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.build(bubble: cell.rightView, with: item)
                cell.canReply = item.status.canReply
                cell.performReply = performReply
                cell.rightView.roundButton.isHidden = item.roundURL == nil
                cell.rightView.didTapShowRound = { showRound(item.roundURL) }

                return cell
            }
        )
    }

    static func outgoingFailedText(performReply: @escaping () -> Void) -> Self {
        .init(
            canBuild: { item in
                (item.status == .failedToSend || item.status == .timedOut)
                && item.payload.reply == nil
                && item.payload.attachment == nil

            }, build: { item, collectionView, indexPath in
                let cell: OutgoingFailedTextCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                Bubbler.build(bubble: cell.rightView, with: item)
                cell.canReply = item.status.canReply
                cell.performReply = performReply
                return cell
            }
        )
    }
}

struct ActionFactory {
    enum Action {
        case copy
        case retry
        case reply
        case delete

        var title: String {
            switch self {

            case .copy:
                return Localized.Chat.BubbleMenu.copy
            case .retry:
                return Localized.Chat.BubbleMenu.retry
            case .reply:
                return Localized.Chat.BubbleMenu.reply
            case .delete:
                return Localized.Chat.BubbleMenu.delete
            }
        }
    }

    static func build(
        from item: ChatItem,
        action: Action,
        closure: @escaping (ChatItem) -> Void
    ) -> UIAction? {

        guard item.payload.attachment == nil else { return nil }

        switch action {
        case .reply:
            guard item.status == .read || item.status == .received || item.status == .sent else { return nil }
        case .retry:
            guard item.status == .failedToSend || item.status == .timedOut else { return nil }
        case .delete, .copy:
            break
        }

        return UIAction(
            title: action.title,
            state: .off,
            handler: { _ in closure(item) }
        )
    }
}
