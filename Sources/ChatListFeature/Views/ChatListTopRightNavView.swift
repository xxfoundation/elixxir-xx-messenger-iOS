import UIKit
import Shared
import Combine

final class ChatListTopRightNavView: UIView {
    enum Action {
        case didTapSearch
        case didTapNewGroup
    }

    var actionPublisher: AnyPublisher<Action, Never> {
        actionSubject.eraseToAnyPublisher()
    }

    private let stackView = UIStackView()
    private let searchButton = UIButton()
    private let newGroupButton = UIButton()
    private let actionSubject = PassthroughSubject<Action, Never>()

    init() {
        super.init(frame: .zero)

        searchButton.tintColor = Asset.neutralDark.color
        newGroupButton.tintColor = Asset.neutralDark.color
        searchButton.setImage(Asset.chatListUd.image, for: .normal)
        newGroupButton.setImage(Asset.chatListNewGroup.image, for: .normal)
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        newGroupButton.addTarget(self, action: #selector(didTapNewGroup), for: .touchUpInside)

        stackView.spacing = 10
        stackView.addArrangedSubview(newGroupButton)
        stackView.addArrangedSubview(searchButton)
        addSubview(stackView)

        searchButton.snp.makeConstraints { $0.width.equalTo(40) }
        newGroupButton.snp.makeConstraints { $0.width.equalTo(40) }
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) { nil }

    @objc private func didTapSearch() {
        actionSubject.send(.didTapSearch)
    }

    @objc private func didTapNewGroup() {
        actionSubject.send(.didTapNewGroup)
    }
}
