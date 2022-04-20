import HUD
import Combine
import Models
import Countries
import Foundation
import Integration
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
    @Dependency private var session: SessionType

    let itemsRelay = CurrentValueSubject<[Contact], Never>([])
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)
    private let placeholderRelay = CurrentValueSubject<Bool, Never>(true)
    private let stateRelay = CurrentValueSubject<SearchViewState, Never>(.init())

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    var state: AnyPublisher<SearchViewState, Never> { stateRelay.eraseToAnyPublisher() }
    var placeholderPublisher: AnyPublisher<Bool, Never> { placeholderRelay.eraseToAnyPublisher() }
    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    func didSelect(filter: SelectedFilter) {
        stateRelay.value.selectedFilter = filter
    }

    func didInput(_ string: String) {
        stateRelay.value.input = string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func didInputPhone(_ string: String) {
        stateRelay.value.phoneInput = string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func didChooseCountry(_ country: Country) {
        stateRelay.value.country = country
    }

    func didTapSearch() {
        hudRelay.send(.on(nil))

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                var content = self.stateRelay.value.selectedFilter.prefix

                if self.stateRelay.value.selectedFilter == .phone {
                    content += self.stateRelay.value.phoneInput + self.stateRelay.value.country.code
                } else {
                    content += self.stateRelay.value.input
                }

                try self.session.search(fact: content) { result in
                    self.placeholderRelay.send(false)

                    switch result {
                    case .success(let searched):
                        self.hudRelay.send(.none)
                        self.itemsRelay.send([searched])
                    case .failure(let error):
                        self.hudRelay.send(.error(.init(with: error)))
                        self.itemsRelay.send([])
                    }
                }
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }
}
