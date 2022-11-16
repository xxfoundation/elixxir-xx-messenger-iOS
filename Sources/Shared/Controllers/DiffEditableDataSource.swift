import UIKit

public struct SectionId: Hashable {
  public init() {}
}

public final class DiffEditableDataSource<SectionIdentifierType, ItemIdentifierType>
: UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
where SectionIdentifierType : Hashable, ItemIdentifierType : Hashable {
  
  public override func tableView(_ tableView: UITableView,
                                 canEditRowAt indexPath: IndexPath) -> Bool { true }
}
