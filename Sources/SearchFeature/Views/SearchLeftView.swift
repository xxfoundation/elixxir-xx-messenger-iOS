import UIKit
import Shared

final class SearchLeftView: UIView {
    let tableView = UITableView()
    let inputField = SearchComponent()
    let emptyView = SearchLeftEmptyView()
    let placeholderView = SearchLeftPlaceholderView()

    init() {
        super.init(frame: .zero)

        emptyView.isHidden = true
        backgroundColor = Asset.neutralWhite.color
        tableView.backgroundColor = Asset.neutralWhite.color

        addSubview(tableView)
        addSubview(inputField)
        addSubview(emptyView)
        addSubview(placeholderView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func updateUIForItem(item: SearchSegmentedControl.Item) {
        let emptyTitle = Localized.Ud.Search.empty(item.written)
        emptyView.titleLabel.text = emptyTitle

        let inputFieldTitle = Localized.Ud.Search.input(item.written)
        inputField.set(placeholder: inputFieldTitle, imageAtRight: nil)
    }

    private func setupConstraints() {
        inputField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(inputField.snp.bottom).offset(20)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints {
            $0.top.equalTo(inputField.snp.bottom).offset(20)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        placeholderView.snp.makeConstraints {
            $0.top.equalTo(inputField.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
