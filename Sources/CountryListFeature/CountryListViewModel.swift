import UIKit
import Shared
import Combine

final class CountryListViewModel {
  var countries: AnyPublisher<NSDiffableDataSourceSnapshot<SectionId, Country>, Never> {
    countriesRelay.eraseToAnyPublisher()
  }

  private var cancellables = Set<AnyCancellable>()
  private let searchQueryRelay = CurrentValueSubject<String, Never>("")
  private let countriesRelay = CurrentValueSubject<NSDiffableDataSourceSnapshot<SectionId, Country>, Never>(.init())

  func fetchCountryList() {
    Publishers
      .CombineLatest(Just(Country.all()), searchQueryRelay)
      .map { countryList, query -> NSDiffableDataSourceSnapshot<SectionId, Country> in
        var snapshot = NSDiffableDataSourceSnapshot<SectionId, Country>()
        let section = SectionId()
        snapshot.appendSections([section])

        guard !query.isEmpty else {
          snapshot.appendItems(countryList, toSection: section)
          return snapshot
        }

        let filtered = countryList.filter {
          $0.name.lowercased().contains(query.lowercased()) ||
          $0.prefix.lowercased().contains(query.lowercased())
        }

        snapshot.appendItems(filtered, toSection: section)
        return snapshot

      }.sink { [weak countriesRelay] in
        countriesRelay?.send($0)
      }.store(in: &cancellables)
  }

  func didSearchFor(_ string: String) {
    searchQueryRelay.send(string)
  }
}
