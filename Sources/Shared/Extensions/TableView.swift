import UIKit

extension UITableViewCell: ReusableView {}
extension UITableViewHeaderFooterView: ReusableView {}

public extension UITableView {
  func register(cells: [AnyClass]) {
    cells.forEach { cell in
      register(cell, forCellReuseIdentifier: String(describing: cell))
    }
  }
  
  func registerHeaderFooter<T: UITableViewHeaderFooterView>(type: T.Type) {
    register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
  }
  
  func register<T: UITableViewCell>(_: T.Type) {
    register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath,
                                               ofType type: T.Type? = nil) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
    }
    
    return cell
  }
  
  func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>(ofType type: T.Type? = nil) -> T {
    guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
      fatalError("Could not dequeue header footer with identifier: \(T.reuseIdentifier)")
    }
    
    return view
  }
}
