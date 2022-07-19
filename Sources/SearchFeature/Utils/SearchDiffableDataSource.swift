import UIKit
import XXModels

enum SearchSection {
    case stranger
    case connections
}

enum SearchItem: Equatable, Hashable {
    case stranger(Contact)
    case connection(Contact)
}

class SearchDiffableDataSource: UITableViewDiffableDataSource<SearchSection, SearchItem> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch snapshot().sectionIdentifiers[section] {
        case .stranger:
            return ""
        case .connections:
            return "CONNECTIONS"
        }
    }
}
