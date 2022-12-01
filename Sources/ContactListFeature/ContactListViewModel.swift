import Combine
import XXModels
import Defaults
import ReportingFeature
import XXMessengerClient

import Foundation
import XXClient

import AppCore
import Dependencies

final class ContactListViewModel {
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.reportingStatus) var reportingStatus

  var myId: Data {
    try! messenger.e2e.get()!.getContact().getId()
  }

  var contacts: AnyPublisher<[XXModels.Contact], Never> {
    let query = Contact.Query(
      authStatus: [.friend],
      isBlocked: reportingStatus.isEnabled() ? false : nil,
      isBanned: reportingStatus.isEnabled() ? false: nil
    )

    return try! dbManager.getDB().fetchContactsPublisher(query)
      .replaceError(with: [])
      .map { $0.filter { $0.id != self.myId }}
      .eraseToAnyPublisher()
  }

  var requestCount: AnyPublisher<Int, Never> {
    let groupQuery = Group.Query(
      authStatus: [.pending],
      isLeaderBlocked: reportingStatus.isEnabled() ? false : nil,
      isLeaderBanned: reportingStatus.isEnabled() ? false : nil
    )

    let contactsQuery = Contact.Query(
      authStatus: [
        .verified,
        .confirming,
        .confirmationFailed,
        .verificationFailed,
        .verificationInProgress
      ],
      isBlocked: reportingStatus.isEnabled() ? false : nil,
      isBanned: reportingStatus.isEnabled() ? false : nil
    )

    return Publishers.CombineLatest(
      try! dbManager.getDB().fetchContactsPublisher(contactsQuery)
        .replaceError(with: []),
      try! dbManager.getDB().fetchGroupsPublisher(groupQuery)
        .replaceError(with: [])
    )
    .map { $0.0.count + $0.1.count }
    .eraseToAnyPublisher()
  }
}
