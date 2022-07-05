import HUD
import UIKit
import Models
import Combine
import Defaults
import XXModels
import Countries
import Foundation
import Integration
import PushFeature
import CombineSchedulers
import DependencyInjection

enum SelectedFilter {
    case username
    case email
    case phone

    var prefix: String {
        switch self {
        case .username:
            return "U"
        case .phone:
            return "P"
        case .email:
            return "E"
        }
    }
}

struct SearchViewState: Equatable {
    var input: String = ""
    var phoneInput: String = ""
    var selectedFilter: SelectedFilter = .username
    var country: Country = .fromMyPhone()
}

final class SearchViewModel {
    @KeyObject(.dummyTrafficOn, defaultValue: false) var isCoverTrafficEnabled: Bool
    @KeyObject(.pushNotifications, defaultValue: false) private var pushNotifications
    @KeyObject(.askedDummyTrafficOnce, defaultValue: false) var offeredCoverTraffic: Bool

    @Dependency private var session: SessionType
    @Dependency private var pushHandler: PushHandling

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var placeholderPublisher: AnyPublisher<Bool, Never> {
        placeholderSubject.eraseToAnyPublisher()
    }

    var coverTrafficPublisher: AnyPublisher<Void, Never> {
        coverTrafficSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<SearchViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var successPublisher: AnyPublisher<Contact, Never> {
        successSubject.eraseToAnyPublisher()
    }

    var backgroundScheduler: AnySchedulerOf<DispatchQueue>
    = DispatchQueue.global().eraseToAnyScheduler()

    let itemsRelay = CurrentValueSubject<[Contact], Never>([])
    private let successSubject = PassthroughSubject<Contact, Never>()
    private let coverTrafficSubject = PassthroughSubject<Void, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let placeholderSubject = CurrentValueSubject<Bool, Never>(true)
    private let stateSubject = CurrentValueSubject<SearchViewState, Never>(.init())

    func didAppear() {
        verifyCoverTraffic()
        verifyNotifications()
    }

    func didSelect(filter: SelectedFilter) {
        stateSubject.value.selectedFilter = filter
    }

    func didInput(_ string: String) {
        stateSubject.value.input = string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func didInputPhone(_ string: String) {
        stateSubject.value.phoneInput = string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func didChooseCountry(_ country: Country) {
        stateSubject.value.country = country
    }

    func didEnableCoverTraffic() {
        isCoverTrafficEnabled = true
        session.setDummyTraffic(status: true)
    }

    func didTapSearch() {
        hudSubject.send(.on(nil))

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                var content = self.stateSubject.value.selectedFilter.prefix

                if self.stateSubject.value.selectedFilter == .phone {
                    content += self.stateSubject.value.phoneInput + self.stateSubject.value.country.code
                } else {
                    content += self.stateSubject.value.input
                }

                try self.session.search(fact: content) { result in
                    self.placeholderSubject.send(false)

                    switch result {
                    case .success(let searched):
                        self.hudSubject.send(.none)
                        self.itemsRelay.send([searched])
                    case .failure(let error):
                        self.hudSubject.send(.error(.init(with: error)))
                        self.itemsRelay.send([])
                    }
                }
            } catch {
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    private func verifyCoverTraffic() {
        guard offeredCoverTraffic == false else {
            return
        }

        offeredCoverTraffic = true
        coverTrafficSubject.send()
    }

    private func verifyNotifications() {
        guard pushNotifications == false else { return }

        pushHandler.requestAuthorization { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let granted):
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }

                self.pushNotifications = granted
            case .failure:
                self.pushNotifications = false
            }
        }
    }

    func didSet(nickname: String, for contact: Contact) {
        var contact = contact
        contact.nickname = nickname

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }
            _ = try? self.session.dbManager.saveContact(contact)
        }
    }

    func didTapRequest(contact: Contact) {
        hudSubject.send(.on(nil))
        var contact = contact
        contact.nickname = contact.username

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.session.add(contact)
                self.hudSubject.send(.none)
                self.successSubject.send(contact)
            } catch {
                self.hudSubject.send(.error(.init(with: error)))
            }
        }

    }
}
