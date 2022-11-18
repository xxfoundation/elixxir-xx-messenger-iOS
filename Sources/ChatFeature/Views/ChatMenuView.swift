import UIKit
import Shared
import Combine
import AppResources

final class ChatMenuView: UIToolbar {
    enum Action {
        case reply
        case delete
        case deleteAll
    }

    // MARK: UI

    let stack = UIStackView()
    let reply = UIButton()
    let delete = UIButton()
    let deleteAll = UIButton()

    // MARK: Properties

    var actionPublisher: AnyPublisher<Action, Never> {
        actionRelay.eraseToAnyPublisher()
    }

    @Published var isReplyEnabled = false
    @Published var isDeleteEnabled = false

    private var cancellables = Set<AnyCancellable>()
    private let actionRelay = PassthroughSubject<Action, Never>()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        layer.cornerRadius = 15
        layer.masksToBounds = true
        barTintColor = Asset.neutralActive.color

        reply.setImage(Asset.lens.image, for: .normal)
        delete.setImage(Asset.lens.image, for: .normal)
        deleteAll.setTitle(Localized.Chat.Menu.deleteAll, for: .normal)

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.addArrangedSubview(reply)
        stack.addArrangedSubview(delete)
        stack.addArrangedSubview(deleteAll)

        addSubview(stack)
        translatesAutoresizingMaskIntoConstraints = false

        $isReplyEnabled
            .assign(to: \.isEnabled, on: reply)
            .store(in: &cancellables)

        $isDeleteEnabled
            .assign(to: \.isEnabled, on: delete)
            .store(in: &cancellables)

        reply
            .publisher(for: .touchUpInside)
            .sink { [weak actionRelay] in actionRelay?.send(.reply) }
            .store(in: &cancellables)

        delete
            .publisher(for: .touchUpInside)
            .sink { [weak actionRelay] in actionRelay?.send(.delete) }
            .store(in: &cancellables)

        deleteAll
            .publisher(for: .touchUpInside)
            .sink { [weak actionRelay] in actionRelay?.send(.deleteAll) }
            .store(in: &cancellables)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(80)
        }
    }
}
