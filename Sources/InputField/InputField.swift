import UIKit
import Shared
import Combine
import AppResources

public final class InputField: UIView {
  public enum Style {
    case phone
    case regular
  }

  public enum LeftView {
    case image(UIImage)
  }

  public enum RightView {
    case image(UIImage)
    case toggleSecureEntry
  }

  public enum ValidationStatus: Equatable {
    case valid(String?)
    case invalid(String)
    case unknown(String?)
  }

  let title = UILabel()
  let hide = UIButton()
  let clear = UIButton()
  let subtitle = UILabel()

  let outerStack = UIStackView()
  let codeContainer = UIView()
  let code = PhoneCodeField()

  let container = UIView()
  let innerStack = UIStackView()
  let left = UIImageView()
  let field = UITextField()

  let toolbar = UIToolbar()
  let toolbarButton = UIButton()

  var isPhone: Bool = false

  // MARK: Properties

  private var rightView: RightView? = .none {
    didSet { set(rightView: rightView) }
  }

  private var clearable: Bool = false
  private var allowsEmptySpace: Bool = true
  private var cancellables = Set<AnyCancellable>()

  private let codeSubject = PassthroughSubject<Void, Never>()
  private let returnSubject = PassthroughSubject<Void, Never>()
  private let textSubject = PassthroughSubject<String, Never>()

  public var codePublisher: AnyPublisher<Void, Never> { codeSubject.eraseToAnyPublisher() }
  public var textPublisher: AnyPublisher<String, Never> { textSubject.eraseToAnyPublisher() }
  public var returnPublisher: AnyPublisher<Void, Never> { returnSubject.eraseToAnyPublisher() }

  public init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) { nil }

  public func makeFirstResponder() {
    field.becomeFirstResponder()
  }

  public func setup(
    style: Style = .regular,
    title: String? = nil,
    placeholder: String? = nil,
    leftView: LeftView? = nil,
    rightView: RightView? = nil,
    accessibility: String? = nil,
    subtitleAccessibility: String? = nil,
    subtitleColor: UIColor = Asset.neutralWhite.color,
    allowsEmptySpace: Bool = true,
    keyboardType: UIKeyboardType = .default,
    autocapitalization: UITextAutocapitalizationType = .sentences,
    autoCorrect: UITextAutocorrectionType = .no,
    contentType: UITextContentType? = nil,
    returnKeyType: UIReturnKeyType = .done,
    toolbarButtonTitle: String = Localized.Shared.done,
    codeAccessibility: String? = nil,
    clearable: Bool = false
  ) {
    self.title.text = title
    self.set(leftView: leftView)

    self.rightView = rightView
    self.field.attributedPlaceholder = NSAttributedString(
      string: placeholder ?? "",
      attributes: [
        .font: Fonts.Mulish.semiBold.font(size: 14.0),
        .foregroundColor: Asset.neutralDisabled.color
      ])

    if contentType == .telephoneNumber {
      isPhone = true
    } else {
      self.field.textContentType = contentType
    }

    self.field.returnKeyType = returnKeyType
    self.field.keyboardType = keyboardType
    self.subtitle.textColor = subtitleColor
    self.allowsEmptySpace = allowsEmptySpace
    self.field.autocorrectionType = autoCorrect
    self.field.accessibilityIdentifier = accessibility
    self.field.autocapitalizationType = autocapitalization
    self.subtitle.accessibilityIdentifier = subtitleAccessibility
    self.clearable = clearable

    if style == .phone {
      codeContainer.addSubview(code)
      code.accessibilityIdentifier = codeAccessibility
      code.snp.makeConstraints { $0.edges.equalToSuperview() }
      outerStack.insertArrangedSubview(codeContainer, at: 0)

      code.publisher(for: .touchUpInside)
        .sink { [weak codeSubject] in codeSubject?.send() }
        .store(in: &cancellables)

      self.field.keyboardType = .numberPad
      self.allowsEmptySpace = false

      toolbar.barTintColor = Asset.neutralWhite.color
      toolbarButton.setTitle(toolbarButtonTitle, for: .normal)
      toolbarButton.setTitleColor(Asset.brandPrimary.color, for: .normal)
      toolbarButton.titleLabel?.font = Fonts.Mulish.bold.font(size: 17.0)
      toolbar.setShadowImage(.color(Asset.neutralLine.color), forToolbarPosition: .any)
      toolbarButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
      toolbar.items = [UIBarButtonItem(customView: toolbarButton.pinning(at: .right(0)))]

      toolbar.sizeToFit()
      self.field.inputAccessoryView = toolbar
    }
  }

  public func set(prefix: String) {
    code.content.text = prefix
  }

  public func update(content: String) {
    field.text = content
  }

  public func update(placeholder: String) {
    field.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [
        .font: Fonts.Mulish.semiBold.font(size: 14.0),
        .foregroundColor: Asset.neutralDisabled.color
      ]
    )
  }

  public func update(status: ValidationStatus) {
    switch status {
    case .unknown(let text):
      set(rightView: nil)
      subtitle.text = text ?? " "
    case .invalid(let text):
      set(rightView: .image(Asset.sharedError.image))
      subtitle.text = text
    case .valid(let text):
      set(rightView: .image(Asset.sharedSuccess.image))
      subtitle.text = text ?? " "
    }
  }

  // MARK: Private

  private func set(leftView: LeftView?) {
    switch leftView {
    case .image(let image):
      left.image = image
      left.tintColor = Asset.neutralDisabled.color
    case .none:
      innerStack.removeArrangedSubview(left)
    }
  }

  public func set(rightView: RightView?) {
    switch rightView {
    case.image(let image):
      field.rightView = UIImageView(image: image)
    case .toggleSecureEntry:
      field.rightView = hide
      field.isSecureTextEntry = true
      hide.setImage(hideButtonImage(isSecureEntry: field.isSecureTextEntry), for: .normal)
    case .none:
      field.rightView = nil
    }
  }

  private func hideButtonImage(isSecureEntry: Bool) -> UIImage? {
    let openImage = Asset.eyeOpen.image.withTintColor(Asset.neutralWeak.color)
    let closedImage = Asset.eyeClosed.image.withTintColor(Asset.neutralWeak.color)
    return isSecureEntry ? closedImage : openImage
  }

  private func setup() {
    subtitle.textAlignment = .right
    subtitle.numberOfLines = 0
    container.layer.cornerRadius = 4
    container.backgroundColor = Asset.neutralSecondary.color

    codeContainer.layer.cornerRadius = 4
    codeContainer.backgroundColor = Asset.neutralSecondary.color

    title.textColor = Asset.neutralWeak.color
    field.textColor = Asset.neutralActive.color
    subtitle.textColor = Asset.neutralWhite.color

    title.font = Fonts.Mulish.regular.font(size: 12.0)
    field.font = Fonts.Mulish.semiBold.font(size: 14.0)
    subtitle.font = Fonts.Mulish.regular.font(size: 12.0)

    clear.setImage(Asset.sharedCross.image, for: .normal)

    field.textPublisher
      .sink { [weak textSubject] in textSubject?.send($0) }
      .store(in: &cancellables)

    hide.publisher(for: .touchUpInside)
      .sink { [unowned self] _ in
        field.isSecureTextEntry.toggle()
        hide.setImage(hideButtonImage(isSecureEntry: field.isSecureTextEntry), for: .normal)
      }.store(in: &cancellables)

    clear.publisher(for: .touchUpInside)
      .sink { [unowned self] in
        field.text = ""
        textSubject.send("")
        field.resignFirstResponder()
      }.store(in: &cancellables)

    field.delegate = self
    field.rightViewMode = .always

    left.contentMode = .center
    left.setContentHuggingPriority(.required, for: .horizontal)

    innerStack.spacing = 12
    innerStack.addArrangedSubview(left)
    innerStack.addArrangedSubview(field)

    outerStack.spacing = 8
    container.addSubview(innerStack)
    outerStack.addArrangedSubview(container)

    addSubview(title)
    addSubview(outerStack)
    addSubview(subtitle)

    setupConstraints()
  }

  private func setupConstraints() {
    title.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview().offset(8)
    }

    outerStack.snp.makeConstraints {
      $0.top.equalTo(title.snp.bottom).offset(10)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.height.equalTo(36)
    }

    innerStack.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview().offset(11)
      $0.right.equalToSuperview().offset(-11)
      $0.bottom.equalToSuperview()
    }

    subtitle.snp.makeConstraints {
      $0.top.equalTo(outerStack.snp.bottom).offset(8)
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.left.greaterThanOrEqualToSuperview()
    }
  }

  @objc private func didTapDone() {
    returnSubject.send()
  }

  public func textFieldDidBeginEditing(_ textField: UITextField) {
    if clearable {
      field.rightView = clear
    }
  }

  public func textFieldDidEndEditing(_ textField: UITextField) {
    if clearable {
      set(rightView: rightView)
    }
  }

  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    returnSubject.send()
    return true
  }

  public func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    if isPhone {
      if string.count > 1 {
        textField.text = string.replaceCharactersFromSet(characterSet: .decimalDigits.inverted)
        textSubject.send(textField.text ?? "")
        return false
      } else {
        return string.rangeOfCharacter(from: .decimalDigits) != nil || string == ""
      }
    }

    if !allowsEmptySpace {
      if string.count > 1 {
        if textField.textContentType == .emailAddress && [".us", ".net", ".edu", ".org", ".com"].contains(string) {
          textSubject.send(textField.text ?? "")
          return true
        }

        textField.text = string.replaceCharactersFromSet(characterSet: .whitespacesAndNewlines)
        textSubject.send(textField.text ?? "")
        return false
      } else {
        return string != " "
      }
    }

    return true
  }
}

extension InputField: UITextFieldDelegate {}

private extension String {
  func replaceCharactersFromSet(characterSet: CharacterSet, replacementString: String = "") -> String {
    return components(separatedBy: characterSet).joined(separator: replacementString)
  }
}
