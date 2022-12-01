import UIKit
import Shared
import Combine
import Defaults
import CloudFiles

import XXClient
import XXModels
import XXDatabase
import XXMessengerClient

import AppCore
import ComposableArchitecture

enum Step {
  case done
  case wrongPass
  case parsingData
  case failDownload(Error)
  case downloading(Float, Float)
  case idle(CloudService, CloudFiles.Fetch.Metadata?)
}

extension Step: Equatable {
  static func ==(lhs: Step, rhs: Step) -> Bool {
    switch (lhs, rhs) {
    case (.done, .done), (.wrongPass, .wrongPass):
      return true
    case let (.failDownload(a), .failDownload(b)):
      return a.localizedDescription == b.localizedDescription
    case let (.downloading(a, b), .downloading(c, d)):
      return a == c && b == d
    case (.idle, _), (.downloading, _), (.parsingData, _),
      (.done, _), (.failDownload, _), (.wrongPass, _):
      return false
    }
  }
}

final class RestoreViewModel {
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger

  @KeyObject(.phone, defaultValue: nil) var phone: String?
  @KeyObject(.email, defaultValue: nil) var email: String?
  @KeyObject(.username, defaultValue: nil) var username: String?

  var stepPublisher: AnyPublisher<Step, Never> {
    stepSubject.eraseToAnyPublisher()
  }

  private var pendingData: Data?
  private var passphrase: String!
  private let details: RestorationDetails
  private let stepSubject: CurrentValueSubject<Step, Never>

  init(details: RestorationDetails) {
    self.details = details
    self.stepSubject = .init(.idle(
      details.provider,
      details.metadata
    ))
  }

  func retryWith(passphrase: String) {
    self.passphrase = passphrase
    continueRestoring(data: pendingData!)
  }

  func didTapRestore(passphrase: String) {
    self.passphrase = passphrase

    guard let metadata = details.metadata else {
      fatalError()
    }

    stepSubject.send(.downloading(0.0, metadata.size))

    do {
      try CloudFilesManager.all[details.provider]!.download { [weak self] in
        guard let self else { return }

        switch $0 {
        case .success(let data):
          guard let data else {
            fatalError("There was metadata, but not data.")
          }
          self.continueRestoring(data: data)
        case .failure(let error):
          self.stepSubject.send(.failDownload(error))
        }
      }
    } catch {
      stepSubject.send(.failDownload(error))
    }
  }

  private func continueRestoring(data: Data) {
    stepSubject.send(.parsingData)

    DispatchQueue.global().async { [weak self] in
      guard let self else { return }

      do {
        print(">>> Calling messenger destroy")
        try self.messenger.destroy()

        print(">>> Calling restore backup")
        let result = try self.messenger.restoreBackup(
          backupData: data,
          backupPassphrase: self.passphrase
        )

        let facts = try self.messenger.ud.tryGet().getFacts()
        self.username = facts.get(.username)!.value
        self.email = facts.get(.email)?.value
        self.phone = facts.get(.phone)?.value

        print(">>> Calling wait for network")
        try self.messenger.waitForNetwork()

        print(">>> Calling waitForNodes")
        try self.messenger.waitForNodes(
          targetRatio: 0.5,
          sleepInterval: 3,
          retries: 15,
          onProgress: { print(">>> \($0)") }
        )

        try self.dbManager.getDB().saveContact(.init(
          id: self.messenger.e2e.get()!.getContact().getId(),
          marshaled: self.messenger.e2e.get()!.getContact().data,
          username: self.username!,
          email: self.email,
          phone: self.phone,
          nickname: nil,
          photo: nil,
          authStatus: .friend,
          isRecent: false,
          isBlocked: false,
          isBanned: false,
          createdAt: Date()
        ))

        print(">>> Calling multilookup")
        let multilookup = try self.messenger.lookupContacts(ids: result.restoredContacts)

        multilookup.contacts.forEach {
          try! self.dbManager.getDB().saveContact(.init(
            id: try $0.getId(),
            marshaled: $0.data,
            username: try? $0.getFact(.username)?.value,
            email: nil,
            phone: nil,
            nickname: try? $0.getFact(.username)?.value,
            photo: nil,
            authStatus: .friend,
            isRecent: false,
            isBlocked: false,
            isBanned: false,
            createdAt: Date()
          ))

          let _ = try! self.messenger.e2e.get()!.resetAuthenticatedChannel(partner: $0)
        }

        try self.messenger.start()

        multilookup.errors.forEach {
          print(">>> Error: \($0.localizedDescription)")
        }

        self.stepSubject.send(.done)
      } catch {
        print(">>> Error on restoration: \(error.localizedDescription)")
        self.pendingData = data
        self.stepSubject.send(.wrongPass)
      }
    }
  }
}
