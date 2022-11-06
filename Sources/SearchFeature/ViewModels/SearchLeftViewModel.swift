import Retry
import UIKit
import Shared
import Combine
import XXModels
import XXClient
import Defaults
import Countries
import CustomDump
import NetworkMonitor
import ReportingFeature
import CombineSchedulers
import XXMessengerClient
import DependencyInjection

typealias SearchSnapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>

struct SearchLeftViewState {
  var input = ""
  var snapshot: SearchSnapshot?
  var country: Country = .fromMyPhone()
  var item: SearchSegmentedControl.Item = .username
}

final class SearchLeftViewModel {
  @Dependency var database: Database
  @Dependency var messenger: Messenger
  @Dependency var hudController: HUDController
  @Dependency var reportingStatus: ReportingStatus
  @Dependency var toastController: ToastController
  @Dependency var networkMonitor: NetworkMonitoring

  @KeyObject(.username, defaultValue: nil) var username: String?
  @KeyObject(.sharingEmail, defaultValue: false) var sharingEmail: Bool
  @KeyObject(.sharingPhone, defaultValue: false) var sharingPhone: Bool

  var myId: Data {
    try! messenger.e2e.get()!.getContact().getId()
  }

  var successPublisher: AnyPublisher<XXModels.Contact, Never> {
    successSubject.eraseToAnyPublisher()
  }

  var statePublisher: AnyPublisher<SearchLeftViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

  var invitation: String?
  private var searchCancellables = Set<AnyCancellable>()
  private let successSubject = PassthroughSubject<XXModels.Contact, Never>()
  private let stateSubject = CurrentValueSubject<SearchLeftViewState, Never>(.init())
  private var networkCancellable = Set<AnyCancellable>()

  init(_ invitation: String? = nil) {
    self.invitation = invitation
  }

  func viewDidAppear() {
    if let pendingInvitation = invitation {
      invitation = nil
      stateSubject.value.input = pendingInvitation
      hudController.show(.init(actionTitle: Localized.Ud.Search.cancel))

      networkCancellable.removeAll()

      networkMonitor.statusPublisher
        .first { $0 == .available }
        .eraseToAnyPublisher()
        .flatMap { _ in
          self.waitForNodes(timeout: 5)
        }.sink(receiveCompletion: {
          if case .failure(let error) = $0 {
            self.hudController.show(.init(error: error))
          }
        }, receiveValue: {
          self.didStartSearching()
        }).store(in: &networkCancellable)
    }
  }

  func didEnterInput(_ string: String) {
    stateSubject.value.input = string
  }

  func didPick(country: Country) {
    stateSubject.value.country = country
  }

  func didSelectItem(_ item: SearchSegmentedControl.Item) {
    stateSubject.value.item = item
  }

  func didTapCancelSearch() {
    searchCancellables.forEach { $0.cancel() }
    searchCancellables.removeAll()
    hudController.dismiss()
  }

  func didStartSearching() {
    guard stateSubject.value.input.isEmpty == false else { return }

    hudController.show(.init(actionTitle: Localized.Ud.Search.cancel))

    var content = stateSubject.value.input

    if stateSubject.value.item == .phone {
      content += stateSubject.value.country.code
    }

    enum NodeRegistrationError: Error {
      case unhealthyNet
      case belowMinimum
    }

    retry(max: 5, retryStrategy: .delay(seconds: 2)) { [weak self] in
      guard let self = self else { return }

      do {
        let nrr = try self.messenger.cMix.get()!.getNodeRegistrationStatus()
        if nrr.ratio < 0.8 { throw NodeRegistrationError.belowMinimum }
      } catch {
        throw NodeRegistrationError.unhealthyNet
      }
    }.finalCatch { [weak self] in
      guard let self = self else { return }

      if case .unhealthyNet = $0 as? NodeRegistrationError {
        self.hudController.show(.init(content: "Network is not healthy yet, try again within the next minute or so."))
      } else if case .belowMinimum = $0 as? NodeRegistrationError {
        self.hudController.show(.init(content:"Node registration ratio is still below 80%, try again within the next minute or so."))
      } else {
        self.hudController.show(.init(error: $0))
      }

      return
    }

    var factType: FactType = .username

    if stateSubject.value.item == .phone {
      factType = .phone
    } else if stateSubject.value.item == .email {
      factType = .email
    }

    backgroundScheduler.schedule { [weak self] in
      guard let self = self else { return }

      do {
        let report = try SearchUD.live(
          params: .init(
            e2eId: self.messenger.e2e.get()!.getId(),
            udContact: self.messenger.ud.get()!.getContact(),
            facts: [.init(type: factType, value: content)]
          ),
          callback: .init(handle: {
            switch $0 {
            case .success(let results):
              self.hudController.dismiss()
              self.appendToLocalSearch(
                XXModels.Contact(
                  id: try! results.first!.getId(),
                  marshaled: results.first!.data,
                  username: try! results.first?.getFacts().first(where: { $0.type == .username })?.value,
                  email: try? results.first?.getFacts().first(where: { $0.type == .email })?.value,
                  phone: try? results.first?.getFacts().first(where: { $0.type == .phone })?.value,
                  nickname: nil,
                  photo: nil,
                  authStatus: .stranger,
                  isRecent: true,
                  isBlocked: false,
                  isBanned: false,
                  createdAt: Date()
                )
              )
            case .failure(let error):
              print(">>> SearchUD error: \(error.localizedDescription)")

              self.appendToLocalSearch(nil)
              self.hudController.show(.init(error: error))
            }
          })
        )

        print(">>> UDSearch.Report: \(report))")
      } catch {
        print(">>> UDSearch.Exception: \(error.localizedDescription)")
      }
    }
  }

  func didTapResend(contact: XXModels.Contact) {
    hudController.show()

    var contact = contact
    contact.authStatus = .requesting

    backgroundScheduler.schedule { [weak self] in
      guard let self = self else { return }

      do {
        try self.database.saveContact(contact)

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

        contact.authStatus = .requested
        contact = try self.database.saveContact(contact)

        self.hudController.dismiss()
        self.presentSuccessToast(for: contact, resent: true)
      } catch {
        contact.authStatus = .requestFailed
        _ = try? self.database.saveContact(contact)
        self.hudController.show(.init(error: error))
      }
    }
  }

  func didTapRequest(contact: XXModels.Contact) {
    hudController.show()

    var contact = contact
    contact.nickname = contact.username
    contact.authStatus = .requesting

    backgroundScheduler.schedule { [weak self] in
      guard let self = self else { return }

      do {
        try self.database.saveContact(contact)

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

        contact.authStatus = .requested
        contact = try self.database.saveContact(contact)

        self.hudController.dismiss()
        self.successSubject.send(contact)
        self.presentSuccessToast(for: contact, resent: false)
      } catch {
        contact.authStatus = .requestFailed
        _ = try? self.database.saveContact(contact)
        self.hudController.show(.init(error: error))
      }
    }
  }

  func didSet(nickname: String, for contact: XXModels.Contact) {
    if var contact = try? database.fetchContacts(.init(id: [contact.id])).first {
      contact.nickname = nickname
      _ = try? database.saveContact(contact)
    }
  }

  private func appendToLocalSearch(_ user: XXModels.Contact?) {
    var snapshot = SearchSnapshot()

    if var user = user {
      if let contact = try? database.fetchContacts(.init(id: [user.id])).first {
        user.isBanned = contact.isBanned
        user.isBlocked = contact.isBlocked
        user.authStatus = contact.authStatus
      }

      if user.authStatus != .friend, !reportingStatus.isEnabled() {
        snapshot.appendSections([.stranger])
        snapshot.appendItems([.stranger(user)], toSection: .stranger)
      } else if user.authStatus != .friend, reportingStatus.isEnabled(), !user.isBanned, !user.isBlocked {
        snapshot.appendSections([.stranger])
        snapshot.appendItems([.stranger(user)], toSection: .stranger)
      }
    }

    let localsQuery = Contact.Query(
      text: stateSubject.value.input,
      authStatus: [.friend],
      isBlocked: reportingStatus.isEnabled() ? false : nil,
      isBanned: reportingStatus.isEnabled() ? false : nil
    )

    if let locals = try? database.fetchContacts(localsQuery),
       let localsWithoutMe = removeMyself(from: locals),
       localsWithoutMe.isEmpty == false {
      snapshot.appendSections([.connections])
      snapshot.appendItems(
        localsWithoutMe.map(SearchItem.connection),
        toSection: .connections
      )
    }

    stateSubject.value.snapshot = snapshot
  }

  private func removeMyself(from collection: [XXModels.Contact]) -> [XXModels.Contact]? {
    collection.filter { $0.id != myId }
  }

  private func presentSuccessToast(for contact: XXModels.Contact, resent: Bool) {
    let name = contact.nickname ?? contact.username
    let sentTitle = Localized.Requests.Sent.Toast.sent(name ?? "")
    let resentTitle = Localized.Requests.Sent.Toast.resent(name ?? "")

    toastController.enqueueToast(model: .init(
      title: resent ? resentTitle : sentTitle,
      leftImage: Asset.sharedSuccess.image
    ))
  }

  private func waitForNodes(timeout: Int) -> AnyPublisher<Void, Error> {
    Deferred {
      Future { promise in
        retry(max: timeout, retryStrategy: .delay(seconds: 1)) { [weak self] in
          guard let self = self else { return }
          _ = try self.messenger.cMix.get()!.getNodeRegistrationStatus()
          promise(.success(()))
        }.finalCatch {
          promise(.failure($0))
        }
      }
    }.eraseToAnyPublisher()
  }
}
