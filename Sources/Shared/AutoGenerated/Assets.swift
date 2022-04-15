// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public static let backupSuccess = ImageAsset(name: "backup_success")
  public static let chatAudioCloseSpeaker = ImageAsset(name: "chat_audio_close_speaker")
  public static let chatAudioOpenSpeaker = ImageAsset(name: "chat_audio_open_speaker")
  public static let chatAudioPause = ImageAsset(name: "chat_audio_pause")
  public static let chatAudioPlay = ImageAsset(name: "chat_audio_play")
  public static let chatAudioSpectrum = ImageAsset(name: "chat_audio_spectrum")
  public static let chatInputActionCamera = ImageAsset(name: "chat_input_action_camera")
  public static let chatInputActionClose = ImageAsset(name: "chat_input_action_close")
  public static let chatInputActionFiles = ImageAsset(name: "chat_input_action_files")
  public static let chatInputActionGallery = ImageAsset(name: "chat_input_action_gallery")
  public static let chatInputActionOpen = ImageAsset(name: "chat_input_action_open")
  public static let chatInputVoicePause = ImageAsset(name: "chat_input_voice_pause")
  public static let chatInputVoicePlay = ImageAsset(name: "chat_input_voice_play")
  public static let chatInputVoiceStart = ImageAsset(name: "chat_input_voice_start")
  public static let chatInputVoiceStop = ImageAsset(name: "chat_input_voice_stop")
  public static let chatLocker = ImageAsset(name: "chat_locker")
  public static let chatMore = ImageAsset(name: "chat_more")
  public static let chatPlaceholderImage = ImageAsset(name: "chat_placeholder_image")
  public static let chatSend = ImageAsset(name: "chat_send")
  public static let chatListDeleteSwipe = ImageAsset(name: "chat_list_delete_swipe")
  public static let chatListMenu = ImageAsset(name: "chat_list_menu")
  public static let chatListMenuDelete = ImageAsset(name: "chat_list_menu_delete")
  public static let chatListMenuPin = ImageAsset(name: "chat_list_menu_pin")
  public static let chatListNew = ImageAsset(name: "chat_list_new")
  public static let chatListPinSwipe = ImageAsset(name: "chat_list_pin_swipe")
  public static let chatListPlaceholder = ImageAsset(name: "chat_list_placeholder")
  public static let code = ImageAsset(name: "code")
  public static let contactAddPlaceholder = ImageAsset(name: "contact_add_placeholder")
  public static let contactDetailsPadlock = ImageAsset(name: "contact_details_padlock")
  public static let contactNicknameEdit = ImageAsset(name: "contact_nickname_edit")
  public static let contactRequestExclamation = ImageAsset(name: "contact_request_exclamation")
  public static let contactRequestPlaceholder = ImageAsset(name: "contact_request_placeholder")
  public static let contactSendMessage = ImageAsset(name: "contact_send_message")
  public static let contactListAvatarRemove = ImageAsset(name: "contactList_avatar_remove")
  public static let contactListNewGroup = ImageAsset(name: "contactList_new_group")
  public static let contactListPlaceholder = ImageAsset(name: "contactList_placeholder")
  public static let contactListRequests = ImageAsset(name: "contactList_requests")
  public static let contactListSearch = ImageAsset(name: "contactList_search")
  public static let contactListUserSearch = ImageAsset(name: "contactList_user_search")
  public static let menuChats = ImageAsset(name: "menu_chats")
  public static let menuContacts = ImageAsset(name: "menu_contacts")
  public static let menuDashboard = ImageAsset(name: "menu_dashboard")
  public static let menuProfile = ImageAsset(name: "menu_profile")
  public static let menuRequests = ImageAsset(name: "menu_requests")
  public static let menuScan = ImageAsset(name: "menu_scan")
  public static let menuSettings = ImageAsset(name: "menu_settings")
  public static let onboardingBackground = ImageAsset(name: "onboarding_background")
  public static let onboardingBottomLogoStart = ImageAsset(name: "onboarding_bottom_logo_start")
  public static let onboardingEmail = ImageAsset(name: "onboarding_email")
  public static let onboardingLogo = ImageAsset(name: "onboarding_logo")
  public static let onboardingLogoStart = ImageAsset(name: "onboarding_logo_start")
  public static let onboardingPhone = ImageAsset(name: "onboarding_phone")
  public static let onboardingSuccess = ImageAsset(name: "onboarding_success")
  public static let permissionCamera = ImageAsset(name: "permission_camera")
  public static let permissionLibrary = ImageAsset(name: "permission_library")
  public static let permissionLogo = ImageAsset(name: "permission_logo")
  public static let permissionMicrophone = ImageAsset(name: "permission_microphone")
  public static let popupNegative = ImageAsset(name: "popup_negative")
  public static let profileAdd = ImageAsset(name: "profile_add")
  public static let profileDelete = ImageAsset(name: "profile_delete")
  public static let profileEmail = ImageAsset(name: "profile_email")
  public static let profileImageButton = ImageAsset(name: "profile_image_button")
  public static let profileImagePlaceholder = ImageAsset(name: "profile_image_placeholder")
  public static let profilePhone = ImageAsset(name: "profile_phone")
  public static let requestsAccept = ImageAsset(name: "requests_accept")
  public static let requestsReceivedPlaceholder = ImageAsset(name: "requests_received_placeholder")
  public static let requestsReject = ImageAsset(name: "requests_reject")
  public static let restoreDrive = ImageAsset(name: "restore_drive")
  public static let restoreDropbox = ImageAsset(name: "restore_dropbox")
  public static let restoreIcloud = ImageAsset(name: "restore_icloud")
  public static let restoreSuccess = ImageAsset(name: "restore_success")
  public static let scanEmail = ImageAsset(name: "scan_email")
  public static let scanError = ImageAsset(name: "scan_error")
  public static let scanPhone = ImageAsset(name: "scan_phone")
  public static let scanQr = ImageAsset(name: "scan_qr")
  public static let scanSuccess = ImageAsset(name: "scan_success")
  public static let searchEmail = ImageAsset(name: "search_email")
  public static let searchLens = ImageAsset(name: "search_lens")
  public static let searchPhone = ImageAsset(name: "search_phone")
  public static let searchPlaceholderImage = ImageAsset(name: "search_placeholder_image")
  public static let searchUsername = ImageAsset(name: "search_username")
  public static let icon32 = ImageAsset(name: "Icon-32")
  public static let settingsAdvanced = ImageAsset(name: "settings_advanced")
  public static let settingsBiometrics = ImageAsset(name: "settings_biometrics")
  public static let settingsCrash = ImageAsset(name: "settings_crash")
  public static let settingsDelete = ImageAsset(name: "settings_delete")
  public static let settingsDeleteLarge = ImageAsset(name: "settings_delete_large")
  public static let settingsDisclosure = ImageAsset(name: "settings_disclosure")
  public static let settingsDownload = ImageAsset(name: "settings_download")
  public static let settingsEnter = ImageAsset(name: "settings_enter")
  public static let settingsFolder = ImageAsset(name: "settings_folder")
  public static let settingsHide = ImageAsset(name: "settings_hide")
  public static let settingsKeyboard = ImageAsset(name: "settings_keyboard")
  public static let settingsLogs = ImageAsset(name: "settings_logs")
  public static let settingsNotifications = ImageAsset(name: "settings_notifications")
  public static let settingsPrivacy = ImageAsset(name: "settings_privacy")
  public static let balloon = ImageAsset(name: "balloon")
  public static let eyeClosed = ImageAsset(name: "eye_closed")
  public static let eyeOpen = ImageAsset(name: "eye_open")
  public static let infoIcon = ImageAsset(name: "info_icon")
  public static let infoIconGrey = ImageAsset(name: "info_icon_grey")
  public static let lens = ImageAsset(name: "lens")
  public static let navigationBarBack = ImageAsset(name: "navigation_bar_back")
  public static let personGray = ImageAsset(name: "person_gray")
  public static let personPlaceholder = ImageAsset(name: "person_placeholder")
  public static let replyAbort = ImageAsset(name: "reply_abort")
  public static let sharedCross = ImageAsset(name: "shared_cross")
  public static let sharedError = ImageAsset(name: "shared_error")
  public static let sharedScan = ImageAsset(name: "shared_scan")
  public static let sharedSuccess = ImageAsset(name: "shared_success")
  public static let sharedWhiteExclamation = ImageAsset(name: "shared_white_exclamation")
  public static let splash = ImageAsset(name: "splash")
  public static let accentDanger = ColorAsset(name: "accent_danger")
  public static let accentSafe = ColorAsset(name: "accent_safe")
  public static let accentSuccess = ColorAsset(name: "accent_success")
  public static let accentWarning = ColorAsset(name: "accent_warning")
  public static let brandBackground = ColorAsset(name: "brand_background")
  public static let brandBubble = ColorAsset(name: "brand_bubble")
  public static let brandDefault = ColorAsset(name: "brand_default")
  public static let brandLight = ColorAsset(name: "brand_light")
  public static let brandPrimary = ColorAsset(name: "brand_primary")
  public static let neutralActive = ColorAsset(name: "neutral_active")
  public static let neutralBody = ColorAsset(name: "neutral_body")
  public static let neutralDark = ColorAsset(name: "neutral_dark")
  public static let neutralDisabled = ColorAsset(name: "neutral_disabled")
  public static let neutralLine = ColorAsset(name: "neutral_line")
  public static let neutralSecondary = ColorAsset(name: "neutral_secondary")
  public static let neutralWeak = ColorAsset(name: "neutral_weak")
  public static let neutralWhite = ColorAsset(name: "neutral_white")
  public static let transferImagePlaceholder = ImageAsset(name: "transfer_image_placeholder")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

public extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
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
