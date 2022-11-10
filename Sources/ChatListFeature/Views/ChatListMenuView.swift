import UIKit
import Shared
import Combine

final class ChatListMenuView: UIToolbar {
  enum Action {
    case delete
    case deleteAll
  }
  
  let stackView = UIStackView()
  let deleteButton = UIButton()
  let deleteAllButton = UIButton()
  
  @Published var isDeleteEnabled = false
  
  var publisher: AnyPublisher<Action, Never> {
    actionRelay.eraseToAnyPublisher()
  }
  
  var cancellables = Set<AnyCancellable>()
  let actionRelay = PassthroughSubject<Action, Never>()
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) { nil }
  
  private func setup() {
    clipsToBounds = true
    layer.cornerRadius = 15
    barTintColor = Asset.neutralSecondary.color
    
    deleteButton.setImage(Asset.chatListMenuDelete.image, for: .normal)
    deleteAllButton.setTitleColor(Asset.accentDanger.color, for: .normal)
    deleteAllButton.setTitle(Localized.ChatList.Menu.deleteAll, for: .normal)
    deleteAllButton.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 14.0)
    
    stackView.spacing = 35
    stackView.addArrangedSubview(deleteButton)
    stackView.addArrangedSubview(deleteAllButton)
    stackView.distribution = .fillEqually
    addSubview(stackView)
    
    translatesAutoresizingMaskIntoConstraints = false
    
    $isDeleteEnabled
      .assign(to: \.isEnabled, on: deleteButton)
      .store(in: &cancellables)
    
    deleteButton
      .publisher(for: .touchUpInside)
      .sink { [weak actionRelay] in
        actionRelay?.send(.delete)
      }.store(in: &cancellables)
    
    deleteAllButton
      .publisher(for: .touchUpInside)
      .sink { [weak actionRelay] in
        actionRelay?.send(.deleteAll)
      }.store(in: &cancellables)
    
    stackView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
      $0.bottom.equalToSuperview().offset(-10)
      $0.height.equalTo(83)
    }
  }
}
