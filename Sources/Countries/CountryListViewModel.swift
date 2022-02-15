import os
import UIKit
import Shared
import Combine
import Foundation

private let logger = Logger(subsystem: "logs_xxmessenger", category: "Countries.CountryListViewModel.swift")

final class CountryListViewModel {
    var countries: AnyPublisher<NSDiffableDataSourceSnapshot<SectionId, Country>, Never> {
        countriesRelay.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let searchQueryRelay = CurrentValueSubject<String, Never>("")
    private let countriesRelay = CurrentValueSubject<NSDiffableDataSourceSnapshot<SectionId, Country>, Never>(.init())

    func fetchCountryList() {
        logger.log("fetchCountryList()")

        Publishers.CombineLatest(Just(Country.all()), searchQueryRelay)
            .map { countryList, query -> NSDiffableDataSourceSnapshot<SectionId, Country> in
                var snapshot = NSDiffableDataSourceSnapshot<SectionId, Country>()
                let section = SectionId()
                snapshot.appendSections([section])

                guard !query.isEmpty else {
                    logger.log("query.isEmpty, returning all countries")
                    snapshot.appendItems(countryList, toSection: section)
                    return snapshot
                }

                let filtered = countryList.filter {
                    $0.name.lowercased().contains(query.lowercased()) ||
                    $0.prefix.lowercased().contains(query.lowercased())
                }

                snapshot.appendItems(filtered, toSection: section)
                return snapshot

            }.sink { [weak countriesRelay] in countriesRelay?.send($0) }
            .store(in: &cancellables)
    }

    func didSearchFor(_ string: String) {
        logger.log("didSearchFor \(string, privacy: .public)()")
        searchQueryRelay.send(string)
    }
}
