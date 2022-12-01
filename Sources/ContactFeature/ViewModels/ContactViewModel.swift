import UIKit
import Shared
import Combine
import AppCore
import XXModels
import Defaults
import XXClient
import Dependencies
import CombineSchedulers
import XXMessengerClient

struct ContactViewState: Equatable {
  var title: String?
  var email: String?
  var phone: String?
  var photo: UIImage?
  var username: String?
  var nickname: String?
}

final class ContactViewModel {
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.app.hudManager) var hudManager
  
  @KeyObject(.username, defaultValue: nil) var username: String?
  @KeyObject(.sharingEmail, defaultValue: false) var sharingEmail: Bool
  @KeyObject(.sharingPhone, defaultValue: false) var sharingPhone: Bool
  
  var contact: XXModels.Contact
  
  var popPublisher: AnyPublisher<Void, Never> { popRelay.eraseToAnyPublisher() }
  var successPublisher: AnyPublisher<Void, Never> { successRelay.eraseToAnyPublisher() }
  var popToRootPublisher: AnyPublisher<Void, Never> { popToRootRelay.eraseToAnyPublisher() }
  var statePublisher: AnyPublisher<ContactViewState, Never> { stateRelay.eraseToAnyPublisher() }
  
  private let popRelay = PassthroughSubject<Void, Never>()
  private let popToRootRelay = PassthroughSubject<Void, Never>()
  private let successRelay = PassthroughSubject<Void, Never>()
  private let stateRelay = CurrentValueSubject<ContactViewState, Never>(.init())
  
  var myId: Data {
    try! messenger.e2e.get()!.getContact().getId()
  }
  
  var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()
  
  init(_ contact: XXModels.Contact) {
    self.contact = contact

    stateRelay.value = .init(
      title: contact.nickname ?? contact.username,
      email: contact.email,
      phone: contact.phone,
      photo: contact.photo != nil ? UIImage(data: contact.photo!) : nil,
      username: contact.username,
      nickname: contact.nickname
    )
  }
  
  func didChoosePhoto(_ photo: UIImage) {
    stateRelay.value.photo = photo
    contact.photo = photo.jpegData(compressionQuality: 0.0)
    _ = try? dbManager.getDB().saveContact(contact)
  }
  
  func didTapDelete() {
    hudManager.show()
    
    do {
      try messenger.e2e.get()!.deleteRequest.partnerId(contact.id)
      try dbManager.getDB().deleteContact(contact)
      
      hudManager.hide()
      popToRootRelay.send()
    } catch {
      hudManager.show(.init(error: error))
    }
  }
  
  func didTapReject() {
    // TODO: Reject function on the API?
    _ = try? dbManager.getDB().deleteContact(contact)
    popRelay.send()
  }
  
  func didTapClear() {
    _ = try? dbManager.getDB().deleteMessages(.init(chat: .direct(myId, contact.id)))
  }
  
  func didUpdateNickname(_ string: String) {
    contact.nickname = string.isEmpty ? nil : string
    stateRelay.value.title = string.isEmpty ? contact.username : string
    _ = try? dbManager.getDB().saveContact(contact)
    
    stateRelay.value.nickname = contact.nickname
  }
  
  func didTapResend() {
    hudManager.show()
    contact.authStatus = .requesting
    
    backgroundScheduler.schedule { [weak self] in
      guard let self else { return }
      
      do {
        try self.dbManager.getDB().saveContact(self.contact)
        
        var includedFacts: [Fact] = []
        let myFacts = try self.messenger.ud.get()!.getFacts()
        
        if let fact = myFacts.get(.username) {
          includedFacts.append(fact)
        }
        
        if self.sharingEmail, let fact = myFacts.get(.email) {
          includedFacts.append(fact)
        }
        
        if self.sharingPhone, let fact = myFacts.get(.phone) {
          includedFacts.append(fact)
        }
        
        let _ = try self.messenger.e2e.get()!.requestAuthenticatedChannel(
          partner: .live(self.contact.marshaled!),
          myFacts: includedFacts
        )
        
        self.contact.authStatus = .requested
        try self.dbManager.getDB().saveContact(self.contact)
        
        self.hudManager.hide()
        self.popRelay.send()
      } catch {
        self.contact.authStatus = .requestFailed
        _ = try? self.dbManager.getDB().saveContact(self.contact)
        self.hudManager.show(.init(error: error))
      }
    }
  }
  
  func didTapRequest(with nickname: String) {
    hudManager.show()
    contact.nickname = nickname
    contact.authStatus = .requesting
    
    backgroundScheduler.schedule { [weak self] in
      guard let self else { return }
      
      do {
        try self.dbManager.getDB().saveContact(self.contact)
        
        var includedFacts: [Fact] = []
        let myFacts = try self.messenger.ud.get()!.getFacts()
        
        if let fact = myFacts.get(.username) {
          includedFacts.append(fact)
        }
        
        if self.sharingEmail, let fact = myFacts.get(.email) {
          includedFacts.append(fact)
        }
        
        if self.sharingPhone, let fact = myFacts.get(.phone) {
          includedFacts.append(fact)
        }
        
        let _ = try self.messenger.e2e.get()!.requestAuthenticatedChannel(
          partner: .live(self.contact.marshaled!),
          myFacts: includedFacts
        )
        
        self.contact.authStatus = .requested
        try self.dbManager.getDB().saveContact(self.contact)
        
        self.hudManager.hide()
        self.successRelay.send()
      } catch {
        self.contact.authStatus = .requestFailed
        _ = try? self.dbManager.getDB().saveContact(self.contact)
        self.hudManager.show(.init(error: error))
      }
    }
  }
  
  func didTapAccept(_ nickname: String) {
    hudManager.show()
    contact.nickname = nickname
    contact.authStatus = .confirming
    
    backgroundScheduler.schedule { [weak self] in
      guard let self else { return }
      
      do {
        try self.dbManager.getDB().saveContact(self.contact)
        
        let _ = try self.messenger.e2e.get()!.confirmReceivedRequest(partner: XXClient.Contact.live(self.contact.marshaled!))
        
        self.contact.authStatus = .friend
        try self.dbManager.getDB().saveContact(self.contact)
        
        self.hudManager.hide()
        self.popRelay.send()
      } catch {
        self.contact.authStatus = .confirmationFailed
        _ = try? self.dbManager.getDB().saveContact(self.contact)
        self.hudManager.show(.init(error: error))
      }
    }
  }
}
