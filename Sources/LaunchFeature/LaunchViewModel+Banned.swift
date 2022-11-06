import Shared
import XXModels
import Foundation

extension LaunchViewModel {
  func updateBannedList(completion: @escaping () -> Void) {
    fetchBannedList { result in
      switch result {
      case .failure(_):
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.updateBannedList(completion: completion)
        }
      case .success(let data):
        self.processBannedList(data, completion: completion)
      }
    }
  }

  func processBannedList(_ data: Data, completion: @escaping () -> Void) {
    processBannedList(
      data: data,
      forEach: { result in
        switch result {
        case .success(let userId):
          let query = Contact.Query(id: [userId])
          if var contact = try! database.fetchContacts(query).first {
            if contact.isBanned == false {
              contact.isBanned = true
              try! database.saveContact(contact)
              self.enqueueBanWarning(contact: contact)
            }
          } else {
            try! database.saveContact(.init(id: userId, isBanned: true))
          }

        case .failure(_):
          break
        }
      },
      completion: { result in
        switch result {
        case .failure(_):
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateBannedList(completion: completion)
          }
        case .success(_):
          completion()
        }
      }
    )
  }

  func enqueueBanWarning(contact: XXModels.Contact) {
    let name = (contact.nickname ?? contact.username) ?? "One of your contacts"
    toastController.enqueueToast(model: .init(
      title: "\(name) has been banned for offensive content.",
      leftImage: Asset.requestSentToaster.image
    ))
  }
}
