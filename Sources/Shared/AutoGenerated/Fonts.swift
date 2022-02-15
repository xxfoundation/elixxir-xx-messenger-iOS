// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
public typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum Fonts {
  public enum Mulish {
    public static let black = FontConvertible(name: "Mulish-Black", family: "Mulish", path: "Mulish-Black.ttf")
    public static let blackItalic = FontConvertible(name: "Mulish-BlackItalic", family: "Mulish", path: "Mulish-BlackItalic.ttf")
    public static let bold = FontConvertible(name: "Mulish-Bold", family: "Mulish", path: "Mulish-Bold.ttf")
    public static let boldItalic = FontConvertible(name: "Mulish-BoldItalic", family: "Mulish", path: "Mulish-BoldItalic.ttf")
    public static let extraBold = FontConvertible(name: "Mulish-ExtraBold", family: "Mulish", path: "Mulish-ExtraBold.ttf")
    public static let extraBoldItalic = FontConvertible(name: "Mulish-ExtraBoldItalic", family: "Mulish", path: "Mulish-ExtraBoldItalic.ttf")
    public static let extraLight = FontConvertible(name: "Mulish-ExtraLight", family: "Mulish", path: "Mulish-ExtraLight.ttf")
    public static let extraLightItalic = FontConvertible(name: "Mulish-ExtraLightItalic", family: "Mulish", path: "Mulish-ExtraLightItalic.ttf")
    public static let italic = FontConvertible(name: "Mulish-Italic", family: "Mulish", path: "Mulish-Italic.ttf")
    public static let light = FontConvertible(name: "Mulish-Light", family: "Mulish", path: "Mulish-Light.ttf")
    public static let lightItalic = FontConvertible(name: "Mulish-LightItalic", family: "Mulish", path: "Mulish-LightItalic.ttf")
    public static let medium = FontConvertible(name: "Mulish-Medium", family: "Mulish", path: "Mulish-Medium.ttf")
    public static let mediumItalic = FontConvertible(name: "Mulish-MediumItalic", family: "Mulish", path: "Mulish-MediumItalic.ttf")
    public static let regular = FontConvertible(name: "Mulish-Regular", family: "Mulish", path: "Mulish-Regular.ttf")
    public static let semiBold = FontConvertible(name: "Mulish-SemiBold", family: "Mulish", path: "Mulish-SemiBold.ttf")
    public static let semiBoldItalic = FontConvertible(name: "Mulish-SemiBoldItalic", family: "Mulish", path: "Mulish-SemiBoldItalic.ttf")
    public static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, extraBold, extraBoldItalic, extraLight, extraLightItalic, italic, light, lightItalic, medium, mediumItalic, regular, semiBold, semiBoldItalic]
  }
  public static let allCustomFonts: [FontConvertible] = [Mulish.all].flatMap { $0 }
  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct FontConvertible {
  public let name: String
  public let family: String
  public let path: String

  #if os(OSX)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Font = UIFont
  #endif

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return BundleToken.bundle.url(forResource: path, withExtension: nil)
  }
}

public extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
