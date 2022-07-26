import UIKit
import Shared
import Combine

typealias CountryListSnapshot = NSDiffableDataSourceSnapshot<Int, Country>

final class CountryListViewModel {
    var queryPublisher: AnyPublisher<String, Never> {
        querySubject.eraseToAnyPublisher()
    }

    var countriesPublisher: AnyPublisher<CountryListSnapshot, Never> {
        countriesSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let querySubject = CurrentValueSubject<String, Never>("")
    private let countriesSubject = CurrentValueSubject<CountryListSnapshot, Never>(.init())

    init() {
        Publishers.CombineLatest(
            Just(Country.all()),
            queryPublisher
        )
        .map(prepareSnapshot(_:))
        .sink { [unowned self] in countriesSubject.send($0) }
        .store(in: &cancellables)
    }

    func didSearchFor(_ string: String) {
        querySubject.send(string)
    }

    private func prepareSnapshot(_ pair: (countries: [Country], query: String)) -> CountryListSnapshot {
        var snapshot = CountryListSnapshot()
        snapshot.appendSections([0])

        guard !pair.query.isEmpty else {
            snapshot.appendItems(pair.countries, toSection: 0)
            return snapshot
        }

        let filtered = pair.countries.filter {
            $0.name.lowercased().contains(pair.query.lowercased()) ||
            $0.prefix.lowercased().contains(pair.query.lowercased())
        }

        snapshot.appendItems(filtered, toSection: 0)
        return snapshot
    }
}
