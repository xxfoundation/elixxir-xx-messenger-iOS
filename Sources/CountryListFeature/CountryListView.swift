import UIKit
import Shared
import AppResources

final class CountryListView: UIView {
  let tableView = UITableView()
  let searchComponent = SearchComponent()

  init() {
    super.init(frame: .zero)

    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    backgroundColor = Asset.neutralWhite.color

    searchComponent.set(
      imageAtRight: UIImage.color(.clear),
      inputAccessibility: Localized.Accessibility.Countries.Search.field,
      rightAccessibility: Localized.Accessibility.Countries.Search.right
    )

    addSubview(tableView)
    addSubview(searchComponent)

    searchComponent.snp.makeConstraints {
      $0.top.equalToSuperview().offset(20)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    tableView.snp.makeConstraints {
      $0.top.equalTo(searchComponent.snp.bottom).offset(20)
      $0.left.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.right.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }
}
