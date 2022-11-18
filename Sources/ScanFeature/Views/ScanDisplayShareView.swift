import UIKit
import Shared
import SnapKit
import Combine
import AppResources

final class ScanDisplayShareView: UIView {
  enum Action {
    case info
    case addEmail
    case addPhone
    case toggleEmail
    case togglePhone
  }
  
  private var isExpanded = false {
    didSet { updateBottomConstraint() }
  }
  
  private let upperView = UIView()
  private let lowerView = UIView()
  private var bottomConstraint: Constraint?
  
  private let imageView = UIImageView()
  private let titleView = TextWithInfoView()
  private let emailView = AttributeSwitcher()
  private let phoneView = AttributeSwitcher()
  private var cancellables = Set<AnyCancellable>()
  
  private var currentConstraintConstant: CGFloat = 0.0 {
    didSet { bottomConstraint?.update(offset: currentConstraintConstant) }
  }
  
  private var bottomConstraintExpanded: CGFloat {
    -lowerView.frame.height
  }
  
  private var bottomConstraintNotExpanded: CGFloat {
    0
  }
  
  var actionPublisher: AnyPublisher<Action, Never> {
    actionSubject.eraseToAnyPublisher()
  }
  
  private let actionSubject = PassthroughSubject<Action, Never>()
  
  init() {
    super.init(frame: .zero)
    
    upperView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(_:))))
    lowerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(_:))))
    
    layer.cornerRadius = 30
    imageView.image = Asset.scanDropdown.image
    backgroundColor = Asset.neutralWhite.color
    clipsToBounds = true
    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    
    addSubview(upperView)
    addSubview(lowerView)
    
    upperView.addSubview(imageView)
    upperView.addSubview(titleView)
    lowerView.addSubview(emailView)
    lowerView.addSubview(phoneView)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byWordWrapping
    
    titleView.setup(
      text: Localized.Scan.Display.Share.title,
      attributes: [
        .foregroundColor: Asset.neutralBody.color,
        .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
        .paragraphStyle: paragraphStyle
      ],
      didTapInfo: { [weak self] in self?.actionSubject.send(.info) }
    )
    
    emailView.switcherView
      .publisher(for: .valueChanged)
      .sink { [unowned self] in actionSubject.send(.toggleEmail) }
      .store(in: &cancellables)
    
    phoneView.switcherView
      .publisher(for: .valueChanged)
      .sink { [unowned self] in actionSubject.send(.togglePhone) }
      .store(in: &cancellables)
    
    emailView.addButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in actionSubject.send(.addEmail) }
      .store(in: &cancellables)
    
    phoneView.addButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in actionSubject.send(.addPhone) }
      .store(in: &cancellables)
    
    emailView.setup(state: nil, title: Localized.Scan.Display.Share.email)
    phoneView.setup(state: nil, title: Localized.Scan.Display.Share.phone)
    emailView.alpha = 0.0
    phoneView.alpha = 0.0
    
    imageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(15)
      $0.centerX.equalToSuperview()
    }
    
    titleView.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(10)
      $0.left.equalToSuperview().offset(40)
      $0.right.lessThanOrEqualToSuperview().offset(-40)
      $0.centerY.equalToSuperview()
    }
    
    emailView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview().offset(40)
      $0.right.equalToSuperview().offset(-40)
    }
    
    phoneView.snp.makeConstraints {
      $0.top.equalTo(emailView.snp.bottom).offset(25)
      $0.left.equalToSuperview().offset(40)
      $0.right.equalToSuperview().offset(-40)
      $0.bottom.equalToSuperview().offset(-40)
    }
    
    upperView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      bottomConstraint = $0.bottom
        .equalTo(safeAreaLayoutGuide)
        .constraint
    }
    
    lowerView.snp.makeConstraints {
      $0.top.equalTo(upperView.snp.bottom).offset(-30)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) { nil }
  
  func setup(email state: AttributeSwitcher.State?) {
    emailView.setup(state: state, title: Localized.Scan.Display.Share.email)
  }
  
  func setup(phone state: AttributeSwitcher.State?) {
    phoneView.setup(state: state, title: Localized.Scan.Display.Share.phone)
  }
  
  @objc private func didPan(_ sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .began, .changed:
      let isUpwards = sender.translation(in: self).y < 0
      let result = currentConstraintConstant + sender.translation(in: self).y
      
      if isUpwards {
        currentConstraintConstant = max(bottomConstraintExpanded, result)
      } else {
        currentConstraintConstant = min(bottomConstraintNotExpanded, result)
      }
      
      let currentMinusExpanded = currentConstraintConstant - bottomConstraintExpanded
      let notExpandedMinusExpanded = bottomConstraintNotExpanded - bottomConstraintExpanded
      let alpha = 1 - (currentMinusExpanded / abs(notExpandedMinusExpanded))
      emailView.alpha = alpha
      phoneView.alpha = alpha
      
    case .cancelled, .ended, .failed:
      let currentMinusExpanded = currentConstraintConstant - bottomConstraintExpanded
      let notExpandedMinusExpanded = bottomConstraintNotExpanded - bottomConstraintExpanded
      let percentage = currentMinusExpanded / abs(notExpandedMinusExpanded)
      isExpanded = percentage < 0.5
      
    case .possible:
      break
    @unknown default:
      break
    }
  }
  
  private func updateBottomConstraint() {
    if isExpanded {
      emailView.alpha = 1.0
      phoneView.alpha = 1.0
      currentConstraintConstant = bottomConstraintExpanded
    } else {
      emailView.alpha = 0.0
      phoneView.alpha = 0.0
      currentConstraintConstant = bottomConstraintNotExpanded
    }
  }
}
