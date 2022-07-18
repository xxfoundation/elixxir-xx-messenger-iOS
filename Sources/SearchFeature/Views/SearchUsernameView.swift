import UIKit
import Shared

final class SearchUsernameView: UIView {
    let tableView = UITableView()
    let inputField = SearchComponent()
    let emptyView: UIView = {
        let view = UIView()
        let label = UILabel()

        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = Fonts.Mulish.regular.font(size: 15.0)
        label.text = Localized.Ud.Search.Username.Empty.title
        label.textColor = Asset.neutralSecondaryAlternative.color

        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }

        return view
    }()

    let placeholderView = SearchUsernamePlaceholderView()

    init() {
        super.init(frame: .zero)

        inputField.set(
            placeholder: Localized.Ud.Search.Username.input,
            imageAtRight: nil
        )

        emptyView.isHidden = true

        addSubview(tableView)
        addSubview(inputField)
        addSubview(emptyView)
        addSubview(placeholderView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

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
            $0.left.equalToSuperview().offset(32.5)
            $0.right.equalToSuperview().offset(-32.5)
            $0.bottom.equalToSuperview()
        }
    }
}
