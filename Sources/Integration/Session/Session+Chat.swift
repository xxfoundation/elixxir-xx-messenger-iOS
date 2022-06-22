import UIKit
import Models
import Shared
import XXModels
import Foundation

extension Session {
    public func send(imageData: Data, to contact: Contact, completion: @escaping (Result<Void, Error>) -> Void) {
//        client.bindings.compress(image: imageData) { [weak self] in
//            guard let self = self else {
//                completion(.success(()))
//                return
//            }
//
//            switch $0 {
//            case .success(let compressed):
//                let name = "image_\(Date.asTimestamp)"
//                try! FileManager.store(data: compressed, name: name, type: Attachment.Extension.image.written)
//                let attachment = Attachment(name: name, data: compressed, _extension: .image)
//                self.send(Payload(text: "You sent an image", reply: nil, attachment: attachment), toContact: contact)
//                completion(.success(()))
//            case .failure(let error):
//                completion(.failure(error))
//                log(string: "Error when compressing image: \(error.localizedDescription)", type: .error)
//            }
//        }
    }

    public func send(_ payload: Payload, toContact contact: Contact) {
        var message = Message(
            networkId: nil,
            senderId: client.bindings.meMarshalled,
            recipientId: contact.id,
            groupId: nil,
            date: Date(),
            status: .sending,
            isUnread: false,
            text: payload.text,
            replyMessageId: payload.reply?.messageId,
            roundURL: nil,
            fileTransferId: nil
        )

        do {
            message = try dbManager.saveMessage(message)
            send(message: message)
        } catch {
            log(string: error.localizedDescription, type: .error)
        }
    }

    public func retryMessage(_ id: Int64) {
        if var message = try? dbManager.fetchMessages(.init(id: [id])).first {
            message.status = .sending
            message.date = Date()

            do {
                message = try dbManager.saveMessage(message)
                send(message: message)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func send(message: Message) {
        var message = message

//        if let _ = message.payload.attachment {
//            sendAttachment(message: message)
//            return
//        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            switch self.client.bindings.send(message.text.data(using: .utf8)!, to: message.recipientId!) {
            case .success(let report):
                message.roundURL = report.roundURL

                self.client.bindings.listen(report: report.marshalled) { result in
                    switch result {
                    case .success(let status):
                        switch status {
                        case .failed:
                            message.status = .sendingFailed
                        case .sent:
                            message.status = .sent
                        case .timedout:
                            message.status = .sendingTimedOut
                        }
                    case .failure:
                        message.status = .sendingFailed
                    }

                    message.networkId = report.uniqueId
                    message.date = Date.fromTimestamp(Int(report.timestamp))
                    DispatchQueue.main.async {
                        do {
                            _ = try self.dbManager.saveMessage(message)
                        } catch {
                            log(string: error.localizedDescription, type: .error)
                        }
                    }
                }
            case .failure(let error):
                message.status = .sendingFailed
                log(string: error.localizedDescription, type: .error)
            }

            DispatchQueue.main.async {
                do {
                    _ = try self.dbManager.saveMessage(message)
                } catch {
                    log(string: error.localizedDescription, type: .error)
                }
            }
        }
    }

//    private func sendAttachment(message: Message) {
//        guard let manager = client.transferManager else { fatalError("A transfer manager was not created") }
//
//        var message = message
//        let attachment = message.payload.attachment!
//
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//
//            do {
//                let tid = try manager.uploadFile(attachment, to: message.receiver) { completed, send, arrived, total, error in
//                    if completed {
//                        self.endTransferFrom(message: message)
//                        message.status = .sent
//                        message.payload.attachment?.progress = 1.0
//                        log(string: "FT Up finished", type: .info)
//                    } else {
//                        if let error = error {
//                            log(string: error.localizedDescription, type: .error)
//                            message.status = .failedToSend
//                        } else {
//                            let progress = Float(arrived)/Float(total)
//                            message.payload.attachment?.progress = progress
//                            log(string: "FT Up: \(progress)", type: .crumbs)
//                        }
//                    }
//
//                    do {
//                        _ = try self.dbManager.save(message) // If it fails here, means the chat was cleared.
//                    } catch {
//                        log(string: error.localizedDescription, type: .error)
//                    }
//                }
//
//                let transfer = FileTransfer(
//                    tid: tid,
//                    contact: message.receiver,
//                    fileName: attachment.name,
//                    fileType: attachment._extension.written,
//                    isIncoming: false
//                )
//
//                message.payload.attachment?.transferId = tid
//                message.status = .sending
//
//                do {
//                    _ = try self.dbManager.saveMessage(message)
//                    _ = try self.dbManager.save(transfer)
//                } catch {
//                    log(string: error.localizedDescription, type: .error)
//                }
//            } catch {
//                message.status = .sendingFailed
//                log(string: error.localizedDescription, type: .error)
//
//                do {
//                    _ = try self.dbManager.saveMessage(message)
//                } catch let otherError {
//                    log(string: otherError.localizedDescription, type: .error)
//                }
//            }
//        }
//    }
//
//    private func endTransferFrom(message: Message) {
//        guard let manager = client.transferManager else { fatalError("A transfer manager was not created") }
//        guard let tid = message.payload.attachment?.transferId else { fatalError("Tried to finish a transfer that had no TID") }
//
//        do {
//            try manager.endTransferUpload(with: tid)
//
//            if let transfer: FileTransfer = try? dbManager.fetch(.withTID(tid)).first {
//                try dbManager.delete(transfer)
//            }
//        } catch {
//            log(string: error.localizedDescription, type: .error)
//        }
//    }
//
//    func handle(incomingTransfer transfer: FileTransfer) {
//        guard let manager = client.transferManager else { fatalError("A transfer manager was not created") }
//
//        let fileExtension: Attachment.Extension = transfer.fileType == "m4a" ? .audio : .image
//        let name = "\(Date.asTimestamp)_\(transfer.fileName)"
//
//        var fakeContent: Data
//
//        if fileExtension == .image {
//            fakeContent = Asset.transferImagePlaceholder.image.jpegData(compressionQuality: 0.1)!
//        } else {
//            fakeContent = FileManager.dummyAudio()
//        }
//
//        let attachment = Attachment(name: name, data: fakeContent, transferId: transfer.tid, _extension: fileExtension)
//
//        var message = Message(
//            sender: transfer.contact,
//            receiver: client.bindings.meMarshalled,
//            payload: .init(text: "Sent you a \(fileExtension.writtenExtended)", reply: nil, attachment: attachment),
//            unread: true,
//            timestamp: Date.asTimestamp,
//            uniqueId: nil,
//            status: .receivingAttachment
//        )
//
//        do {
//            message = try self.dbManager.saveMessage(message)
//            try self.dbManager.save(transfer)
//        } catch {
//            log(string: "Failed to save message/transfer to the database. Will not start listening to transfer... \(error.localizedDescription)", type: .info)
//            return
//        }
//
//        log(string: "FT Down starting", type: .info)
//
//        try! manager.listenDownloadFromTransfer(with: transfer.tid) { completed, arrived, total, error in
//            if let error = error {
//                fatalError(error.localizedDescription)
//            }
//
//            if completed {
//                log(string: "FT Down finished", type: .info)
//
//                guard let rawFile = try? manager.downloadFileFromTransfer(with: transfer.tid) else {
//                    log(string: "Received finalized transfer, file was nil. Ignoring...", type: .error)
//                    return
//                }
//
//                try! FileManager.store(data: rawFile, name: name, type: fileExtension.written)
//                var realAttachment = Attachment(name: name, data: rawFile, transferId: transfer.tid, _extension: fileExtension)
//                realAttachment.progress = 1.0
//                message.payload = .init(text: "Sent you a \(transfer.fileType)", reply: nil, attachment: realAttachment)
//                message.status = .received
//
//                if let toDelete: FileTransfer = try? self.dbManager.fetch(.withTID(transfer.tid)).first {
//                    do {
//                        try self.dbManager.delete(toDelete)
//                    } catch {
//                        log(string: error.localizedDescription, type: .error)
//                    }
//                }
//            } else {
//                let progress = Float(arrived)/Float(total)
//                log(string: "FT Down: \(progress)", type: .crumbs)
//                message.payload.attachment?.progress = progress
//            }
//
//            do {
//                try self.dbManager.save(message) // If it fails here, means the chat was cleared.
//            } catch {
//                log(string: "Failed to update message model from an incoming transfer. Probably chat was cleared: \(error.localizedDescription)", type: .error)
//            }
//        }
//    }
}
