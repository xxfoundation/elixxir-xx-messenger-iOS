import AppResources
import Combine
import SwiftUI
import UIKit

public struct CapsuleButtonModel {
  public var title: String
  public var accessibility: String?
  public var style: CapsuleButtonStyle

  public init(
    title: String,
    style: CapsuleButtonStyle,
    accessibility: String? = nil
  ) {
    self.title = title
    self.style = style
    self.accessibility = accessibility
  }
}

public struct CapsuleButtonStyle {
  var fill: UIImage
  var borderWidth: CGFloat
  var borderColor: UIColor?
  var titleColor: UIColor
  var disabledTitleColor: UIColor
}

public extension CapsuleButtonStyle {
  static let white = CapsuleButtonStyle(
    fill: .color(Asset.neutralWhite.color),
    borderWidth: 0,
    borderColor: nil,
    titleColor: Asset.brandPrimary.color,
    disabledTitleColor: Asset.neutralWhite.color.withAlphaComponent(0.5)
  )

  static let brandColored = CapsuleButtonStyle(
    fill: .color(Asset.brandPrimary.color),
    borderWidth: 0,
    borderColor: nil,
    titleColor: Asset.neutralWhite.color,
    disabledTitleColor: Asset.neutralWhite.color
  )

  static let red = CapsuleButtonStyle(
    fill: .color(Asset.accentDanger.color),
    borderWidth: 0,
    borderColor: nil,
    titleColor: Asset.neutralWhite.color,
    disabledTitleColor: Asset.neutralWhite.color
  )

  static let seeThroughWhite = CapsuleButtonStyle(
    fill: .color(UIColor.clear),
    borderWidth: 2,
    borderColor: Asset.neutralWhite.color,
    titleColor: Asset.neutralWhite.color,
    disabledTitleColor: Asset.neutralWhite.color.withAlphaComponent(0.5)
  )

  static let seeThrough = CapsuleButtonStyle(
    fill: .color(UIColor.clear),
    borderWidth: 2,
    borderColor: Asset.brandPrimary.color,
    titleColor: Asset.brandPrimary.color,
    disabledTitleColor: Asset.brandPrimary.color.withAlphaComponent(0.5)
  )

  static let simplestColoredRed = CapsuleButtonStyle(
    fill: .color(UIColor.clear),
    borderWidth: 0,
    borderColor: nil,
    titleColor: Asset.accentDanger.color,
    disabledTitleColor: Asset.brandDefault.color.withAlphaComponent(0.5)
  )

  static let simplestColoredBrand = CapsuleButtonStyle(
    fill: .color(UIColor.clear),
    borderWidth: 0,
    borderColor: nil,
    titleColor: Asset.brandPrimary.color,
    disabledTitleColor: Asset.brandDefault.color.withAlphaComponent(0.5)
  )
}

public final class CapsuleButton: UIButton {
  private let height: CGFloat
  private let minimumWidth: CGFloat

  public init(
    height: CGFloat = 55.0,
    minimumWidth: CGFloat = 200
  ) {
    self.height = height
    self.minimumWidth = minimumWidth
    super.init(frame: .zero)

    layer.cornerRadius = 55/2
    layer.masksToBounds = true
    titleLabel!.font = Fonts.Mulish.semiBold.font(size: 16.0)
    adjustsImageWhenHighlighted = false

    setBackgroundImage(.color(Asset.neutralDisabled.color), for: .disabled)

    snp.makeConstraints {
      $0.height.equalTo(height)
      $0.width.greaterThanOrEqualTo(minimumWidth)
    }
  }

  required init?(coder: NSCoder) { nil }

  public override var intrinsicContentSize: CGSize {
    CGSize(width: minimumWidth, height: height)
  }

  public func set(
    style: CapsuleButtonStyle,
    title: String,
    accessibility: String? = nil
  ) {
    setTitle(title, for: .normal)
    accessibilityIdentifier = accessibility
    layer.borderWidth = style.borderWidth

    if let color = style.borderColor {
      layer.borderColor = color.cgColor
    }

    setBackgroundImage(style.fill, for: .normal)
    setTitleColor(style.titleColor, for: .normal)
    setTitleColor(style.disabledTitleColor, for: .disabled)
  }

  public func setStyle(_ style: CapsuleButtonStyle) {
    layer.borderWidth = style.borderWidth

    if let color = style.borderColor {
      layer.borderColor = color.cgColor
    }

    setBackgroundImage(style.fill, for: .normal)
    setTitleColor(style.titleColor, for: .normal)
    setTitleColor(style.disabledTitleColor, for: .disabled)
  }
}

extension CapsuleButton {
  public struct SwiftUIView: UIViewRepresentable {
    public final class Coordinator {
      init(view: CapsuleButton.SwiftUIView) {
        self.view = view
      }

      var view: CapsuleButton.SwiftUIView
      var cancellables = Set<AnyCancellable>()
    }

    public init(
      height: CGFloat = 55.0,
      minimumWidth: CGFloat = 200,
      style: CapsuleButtonStyle,
      title: String,
      accessibility: String? = nil,
      action: @escaping () -> Void
    ) {
      self.height = height
      self.minimumWidth = minimumWidth
      self.style = style
      self.title = title
      self.accessibility = accessibility
      self.action = action
    }

    let height: CGFloat
    let minimumWidth: CGFloat
    var style: CapsuleButtonStyle
    var title: String
    var accessibility: String?
    var action: () -> Void

    public func makeCoordinator() -> Coordinator {
      Coordinator(view: self)
    }

    public func makeUIView(context: Context) -> CapsuleButton {
      let uiView = CapsuleButton(
        height: height,
        minimumWidth: minimumWidth
      )
      uiView.publisher(for: .touchUpInside)
        .sink { context.coordinator.view.action() }
        .store(in: &context.coordinator.cancellables)
      return uiView
    }

    public func updateUIView(_ uiView: CapsuleButton, context: Context) {
      uiView.set(
        style: style,
        title: title,
        accessibility: accessibility
      )
    }
  }
}
