import UIKit
import Models
import Shared
import XXModels
import Foundation

extension Session {
    public func send(imageData: Data, to contact: Contact, completion: @escaping (Result<Void, Error>) -> Void) {
        client.bindings.compress(image: imageData) { [weak self] result in
            guard let self = self else {
                completion(.success(()))
                return
            }

            switch result {
            case .success(let compressedImage):
                do {
                    let url = try FileManager.store(
                        data: compressedImage,
                        name: "image_\(Date.asTimestamp)",
                        type: "jpeg"
                    )

                    self.sendFile(url: url, to: contact)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
                log(string: "Error when compressing image: \(error.localizedDescription)", type: .error)
            }
        }
    }

    public func sendFile(url: URL, to contact: Contact) {
        guard let manager = client.transferManager else { fatalError("A transfer manager was not created") }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            var tid: Data?

            do {
                tid = try manager.uploadFile(url: url, to: contact.id) { completed, send, arrived, total, error in
                    guard let tid = tid else { return }

                    if completed {
                        self.endTransferWith(tid: tid)
                    } else {
                        if error != nil {
                            self.failTransferWith(tid: tid)
                        } else {
                            self.progressTransferWith(tid: tid, arrived: Float(arrived), total: Float(total))
                        }
                    }
                }

                guard let tid = tid else { return }

                let content = url.pathExtension == "m4a" ? "a voice message" : "an image"

                let transfer = FileTransfer(
                    id: tid,
                    contactId: contact.id,
                    name: url.deletingPathExtension().lastPathComponent,
                    type: url.pathExtension,
                    data: try? Data(contentsOf: url),
                    progress: 0.0,
                    isIncoming: false,
                    createdAt: Date()
                )

                _ = try? self.dbManager.saveFileTransfer(transfer)

                let message = Message(
                    networkId: nil,
                    senderId: self.client.bindings.myId,
                    recipientId: contact.id,
                    groupId: nil,
                    date: Date(),
                    status: .sending,
                    isUnread: false,
                    text: "You sent \(content)",
                    replyMessageId: nil,
                    roundURL: nil,
                    fileTransferId: tid
                )

                _ = try? self.dbManager.saveMessage(message)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    public func send(_ payload: Payload, toContact contact: Contact) {
        var message = Message(
            networkId: nil,
            senderId: client.bindings.myId,
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

            if let message = try? dbManager.saveMessage(message) {
                send(message: message)
            }
        }
    }

    private func send(message: Message) {
        var message = message

        var reply: Reply?
        if let replyId = message.replyMessageId,
           let replyMessage = try? dbManager.fetchMessages(Message.Query(networkId: replyId)).first {
            reply = Reply(messageId: replyId, senderId: replyMessage.senderId)
        }

        let payloadData = Payload(text: message.text, reply: reply).asData()

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            switch self.client.bindings.send(payloadData, to: message.recipientId!) {
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

    private func endTransferWith(tid: Data) {
        guard let manager = client.transferManager else {
            fatalError("A transfer manager was not created")
        }

        try? manager.endTransferUpload(with: tid)

        if var message = try? dbManager.fetchMessages(.init(fileTransferId: tid)).first {
            message.status = .sent
            _ = try? dbManager.saveMessage(message)
        }

        if var transfer = try? dbManager.fetchFileTransfers(.init(id: [tid])).first {
            transfer.progress = 1.0
            _ = try? dbManager.saveFileTransfer(transfer)
        }
    }

    private func failTransferWith(tid: Data) {
        if var message = try? dbManager.fetchMessages(.init(fileTransferId: tid)).first {
            message.status = .sendingFailed
            _ = try? dbManager.saveMessage(message)
        }
    }

    private func progressTransferWith(tid: Data, arrived: Float, total: Float) {
        if var transfer = try? dbManager.fetchFileTransfers(.init(id: [tid])).first {
            transfer.progress = arrived/total
            _ = try? dbManager.saveFileTransfer(transfer)
        }
    }

    func handle(incomingTransfer transfer: FileTransfer) {
        guard let manager = client.transferManager else {
            fatalError("A transfer manager was not created")
        }

        let content = transfer.type == "m4a" ? "a voice message" : "an image"

        var message = Message(
            networkId: nil,
            senderId: transfer.contactId,
            recipientId: myId,
            groupId: nil,
            date: transfer.createdAt,
            status: .receiving,
            isUnread: true,
            text: "Sent you \(content)",
            replyMessageId: nil,
            roundURL: nil,
            fileTransferId: transfer.id
        )

        message = try! self.dbManager.saveMessage(message)

        try! manager.listenDownloadFromTransfer(with: transfer.id) { completed, arrived, total, error in
            if let error = error { fatalError(error.localizedDescription) }

            if completed {
                guard let rawFile = try? manager.downloadFileFromTransfer(with: transfer.id) else { return }
                _ = try! FileManager.store(data: rawFile, name: transfer.name, type: transfer.type)

                var transfer = transfer
                transfer.data = rawFile
                transfer.progress = 1.0
                _ = try? self.dbManager.saveFileTransfer(transfer)

                message.status = .received
                _ = try? self.dbManager.saveMessage(message)
            } else {
                self.progressTransferWith(tid: transfer.id, arrived: Float(arrived), total: Float(total))
            }
        }
    }
}
