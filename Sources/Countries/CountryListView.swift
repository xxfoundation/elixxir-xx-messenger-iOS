import UIKit
import Shared

final class CountryListView: UIView {
    let tableView = UITableView()
    let searchComponent = SearchComponent()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
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

        searchComponent.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchComponent.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}
