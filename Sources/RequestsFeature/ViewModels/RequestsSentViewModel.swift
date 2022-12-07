import UIKit
import Shared
import AppCore
import Combine
import Defaults
import XXModels
import Defaults
import XXClient
import AppResources
import Dependencies
import ReportingFeature
import CombineSchedulers
import XXMessengerClient

struct RequestSent: Hashable, Equatable {
  var request: Request
  var isResent: Bool = false
}

final class RequestsSentViewModel {
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.hudManager) var hudManager
  @Dependency(\.app.toastManager) var toastManager
  @Dependency(\.reportingStatus) var reportingStatus
  
  @KeyObject(.username, defaultValue: nil) var username: String?
  @KeyObject(.sharingEmail, defaultValue: false) var sharingEmail: Bool
  @KeyObject(.sharingPhone, defaultValue: false) var sharingPhone: Bool

  var itemsPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<Section, RequestSent>, Never> {
    itemsSubject.eraseToAnyPublisher()
  }
  
  private var cancellables = Set<AnyCancellable>()
  private let itemsSubject = CurrentValueSubject<NSDiffableDataSourceSnapshot<Section, RequestSent>, Never>(.init())
  
  var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()
  
  init() {
    let query = Contact.Query(
      authStatus: [
        .requested,
        .requesting
      ],
      isBlocked: reportingStatus.isEnabled() ? false : nil,
      isBanned: reportingStatus.isEnabled() ? false : nil
    )
    
    try! dbManager.getDB().fetchContactsPublisher(query)
      .replaceError(with: [])
      .removeDuplicates()
      .map { data -> NSDiffableDataSourceSnapshot<Section, RequestSent> in
        var snapshot = NSDiffableDataSourceSnapshot<Section, RequestSent>()
        snapshot.appendSections([.appearing])
        snapshot.appendItems(data.map { RequestSent(request: .contact($0)) }, toSection: .appearing)
        return snapshot
      }.sink { [unowned self] in itemsSubject.send($0) }
      .store(in: &cancellables)
  }
  
  func didTapStateButtonFor(request item: RequestSent) {
    guard case let .contact(contact) = item.request,
          item.request.status == .requested ||
            item.request.status == .requesting ||
            item.request.status == .failedToRequest else {
      return
    }
    
    let name = (contact.nickname ?? contact.username) ?? ""
    
    hudManager.show()
    backgroundScheduler.schedule { [weak self] in
      guard let self else { return }
      
      do {
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
          partner: .live(contact.marshaled!),
          myFacts: includedFacts
        )
        
        self.hudManager.hide()
        
        var item = item
        var allRequests = self.itemsSubject.value.itemIdentifiers
        
        if let indexOfRequest = allRequests.firstIndex(of: item) {
          allRequests.remove(at: indexOfRequest)
        }
        
        item.isResent = true
        allRequests.append(item)
        
        self.toastManager.enqueue(.init(
          title: Localized.Requests.Sent.Toast.resent(name),
          leftImage: Asset.requestSentToaster.image
        ))
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, RequestSent>()
        snapshot.appendSections([.appearing])
        snapshot.appendItems(allRequests, toSection: .appearing)
        self.itemsSubject.send(snapshot)
      } catch {
        self.toastManager.enqueue(.init(
          title: Localized.Requests.Sent.Toast.resentFailed(name),
          leftImage: Asset.requestFailedToaster.image
        ))
        
        let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
        self.hudManager.show(.init(content: xxError))
      }
    }
  }
}
