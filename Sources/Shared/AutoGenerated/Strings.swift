// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Localized {

  public enum Accessibility {
    public enum ChatList {
      /// chatList.menu
      public static let menu = Localized.tr("Localizable", "accessibility.chatList.menu")
      /// chatList.new
      public static let new = Localized.tr("Localizable", "accessibility.chatList.new")
    }
    public enum ContactList {
      /// contactList.newGroup
      public static let newGroup = Localized.tr("Localizable", "accessibility.contactList.newGroup")
      /// contactList.search
      public static let search = Localized.tr("Localizable", "accessibility.contactList.search")
    }
    public enum Countries {
      public enum Search {
        /// countries.search.field
        public static let field = Localized.tr("Localizable", "accessibility.countries.search.field")
        /// countries.search.right
        public static let `right` = Localized.tr("Localizable", "accessibility.countries.search.right")
      }
    }
    public enum CreateGroup {
      /// createGroup.create
      public static let create = Localized.tr("Localizable", "accessibility.createGroup.create")
      public enum Drawer {
        /// createGroup.drawer.create
        public static let create = Localized.tr("Localizable", "accessibility.createGroup.drawer.create")
        /// createGroup.drawer.input
        public static let input = Localized.tr("Localizable", "accessibility.createGroup.drawer.input")
        /// createGroup.drawer.otherInput
        public static let otherInput = Localized.tr("Localizable", "accessibility.createGroup.drawer.otherInput")
      }
    }
    public enum Menu {
      /// menu.chats
      public static let chats = Localized.tr("Localizable", "accessibility.menu.chats")
      /// menu.contacts
      public static let contacts = Localized.tr("Localizable", "accessibility.menu.contacts")
      /// menu.dashboard
      public static let dashboard = Localized.tr("Localizable", "accessibility.menu.dashboard")
      /// menu.header
      public static let header = Localized.tr("Localizable", "accessibility.menu.header")
      /// menu.profile
      public static let profile = Localized.tr("Localizable", "accessibility.menu.profile")
      /// menu.requests
      public static let requests = Localized.tr("Localizable", "accessibility.menu.requests")
      /// menu.scan
      public static let scan = Localized.tr("Localizable", "accessibility.menu.scan")
      /// menu.settings
      public static let settings = Localized.tr("Localizable", "accessibility.menu.settings")
    }
    public enum Onboarding {
      public enum Code {
        /// onboarding.code.finish
        public static let finish = Localized.tr("Localizable", "accessibility.onboarding.code.finish")
        /// onboarding.code.resend
        public static let resend = Localized.tr("Localizable", "accessibility.onboarding.code.resend")
        /// onboarding.code.textfield
        public static let textfield = Localized.tr("Localizable", "accessibility.onboarding.code.textfield")
      }
      public enum Email {
        /// onboarding.email.next
        public static let next = Localized.tr("Localizable", "accessibility.onboarding.email.next")
        /// onboarding.email.skip
        public static let skip = Localized.tr("Localizable", "accessibility.onboarding.email.skip")
        /// onboarding.email.subtitle
        public static let subtitle = Localized.tr("Localizable", "accessibility.onboarding.email.subtitle")
        /// onboarding.email.textfield
        public static let textfield = Localized.tr("Localizable", "accessibility.onboarding.email.textfield")
      }
      public enum Phone {
        /// onboarding.phone.code
        public static let code = Localized.tr("Localizable", "accessibility.onboarding.phone.code")
        /// onboarding.phone.next
        public static let next = Localized.tr("Localizable", "accessibility.onboarding.phone.next")
        /// onboarding.phone.skip
        public static let skip = Localized.tr("Localizable", "accessibility.onboarding.phone.skip")
        /// onboarding.phone.subtitle
        public static let subtitle = Localized.tr("Localizable", "accessibility.onboarding.phone.subtitle")
        /// onboarding.phone.textfield
        public static let textfield = Localized.tr("Localizable", "accessibility.onboarding.phone.textfield")
      }
      public enum Success {
        /// onboarding.success.action
        public static let action = Localized.tr("Localizable", "accessibility.onboarding.success.action")
      }
      public enum Username {
        /// onboarding.username.button
        public static let button = Localized.tr("Localizable", "accessibility.onboarding.username.button")
        /// onboarding.username.subtitle
        public static let subtitle = Localized.tr("Localizable", "accessibility.onboarding.username.subtitle")
        /// onboarding.username.textfield
        public static let textfield = Localized.tr("Localizable", "accessibility.onboarding.username.textfield")
      }
    }
    public enum Profile {
      public enum Email {
        /// profile.email.button
        public static let button = Localized.tr("Localizable", "accessibility.profile.email.button")
        /// profile.email.content
        public static let content = Localized.tr("Localizable", "accessibility.profile.email.content")
      }
      public enum Phone {
        /// profile.phone.button
        public static let button = Localized.tr("Localizable", "accessibility.profile.phone.button")
        /// profile.phone.content
        public static let content = Localized.tr("Localizable", "accessibility.profile.phone.content")
      }
    }
    public enum Qr {
      /// qr.left
      public static let `left` = Localized.tr("Localizable", "accessibility.qr.left")
      /// qr.right
      public static let `right` = Localized.tr("Localizable", "accessibility.qr.right")
    }
    public enum Requests {
      public enum Failed {
        /// requests.failed.tab
        public static let tab = Localized.tr("Localizable", "accessibility.requests.failed.tab")
      }
      public enum Received {
        /// requests.received.tab
        public static let tab = Localized.tr("Localizable", "accessibility.requests.received.tab")
      }
      public enum Sent {
        /// requests.sent.tab
        public static let tab = Localized.tr("Localizable", "accessibility.requests.sent.tab")
      }
    }
    public enum Search {
      /// search.countryCode
      public static let countryCode = Localized.tr("Localizable", "accessibility.search.countryCode")
      /// search.email
      public static let email = Localized.tr("Localizable", "accessibility.search.email")
      /// search.input
      public static let input = Localized.tr("Localizable", "accessibility.search.input")
      /// search.phone
      public static let phone = Localized.tr("Localizable", "accessibility.search.phone")
      /// search.phoneInput
      public static let phoneInput = Localized.tr("Localizable", "accessibility.search.phoneInput")
      /// search.username
      public static let username = Localized.tr("Localizable", "accessibility.search.username")
      public enum Placeholder {
        /// search.placeholder.action
        public static let action = Localized.tr("Localizable", "accessibility.search.placeholder.action")
        /// search.placeholder.image
        public static let image = Localized.tr("Localizable", "accessibility.search.placeholder.image")
        /// search.placeholder.text
        public static let text = Localized.tr("Localizable", "accessibility.search.placeholder.text")
      }
    }
    public enum Shared {
      public enum Search {
        /// shared.search.rightButton
        public static let rightButton = Localized.tr("Localizable", "accessibility.shared.search.rightButton")
        /// shared.search.textField
        public static let textField = Localized.tr("Localizable", "accessibility.shared.search.textField")
      }
    }
  }

  public enum AccountRestore {
    /// Account restore
    public static let header = Localized.tr("Localizable", "accountRestore.header")
    public enum Found {
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "accountRestore.found.cancel")
      /// BACKUP DATE
      public static let date = Localized.tr("Localizable", "accountRestore.found.date")
      /// Next
      public static let next = Localized.tr("Localizable", "accountRestore.found.next")
      /// Restore account
      public static let restore = Localized.tr("Localizable", "accountRestore.found.restore")
      /// FILE SIZE
      public static let size = Localized.tr("Localizable", "accountRestore.found.size")
      /// Restore your contacts from the following backup.
      public static let subtitle = Localized.tr("Localizable", "accountRestore.found.subtitle")
      /// Backup found
      public static let title = Localized.tr("Localizable", "accountRestore.found.title")
    }
    public enum List {
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "accountRestore.list.cancel")
      /// Restore your account from a previous backup. You’ll be able to have access to all your contacts.
      public static let firstSubtitle = Localized.tr("Localizable", "accountRestore.list.firstSubtitle")
      /// Select the cloud storage service you previously used to create a backup.
      public static let secondSubtitle = Localized.tr("Localizable", "accountRestore.list.secondSubtitle")
      /// Restore your #account#.
      public static let title = Localized.tr("Localizable", "accountRestore.list.title")
    }
    public enum NotFound {
      /// Go back
      public static let back = Localized.tr("Localizable", "accountRestore.notFound.back")
      /// No account backup was found in %@
      public static func subtitle(_ p1: Any) -> String {
        return Localized.tr("Localizable", "accountRestore.notFound.subtitle", String(describing: p1))
      }
      /// Backup not found
      public static let title = Localized.tr("Localizable", "accountRestore.notFound.title")
    }
    public enum Sftp {
      /// Host
      public static let host = Localized.tr("Localizable", "accountRestore.sftp.host")
      /// Login
      public static let login = Localized.tr("Localizable", "accountRestore.sftp.login")
      /// Password
      public static let password = Localized.tr("Localizable", "accountRestore.sftp.password")
      /// Login to your server. Your credentials will be automatically and securley saved locally on your device.
      public static let subtitle = Localized.tr("Localizable", "accountRestore.sftp.subtitle")
      /// Login to your SFTP
      public static let title = Localized.tr("Localizable", "accountRestore.sftp.title")
      /// Username
      public static let username = Localized.tr("Localizable", "accountRestore.sftp.username")
    }
    public enum Success {
      /// You now have access to all your contacts.
      public static let subtitle = Localized.tr("Localizable", "accountRestore.success.subtitle")
      /// Your #account# has been successfully #restored#.
      public static let title = Localized.tr("Localizable", "accountRestore.success.title")
    }
    public enum Warning {
      /// I understand
      public static let action = Localized.tr("Localizable", "accountRestore.warning.action")
      /// xx messenger account can only run on a single device at a time. Using the same account on multiple devices may permanently damage your account and make it impossible to converse with your contacts
      public static let subtitle = Localized.tr("Localizable", "accountRestore.warning.subtitle")
      /// Warning
      public static let title = Localized.tr("Localizable", "accountRestore.warning.title")
    }
  }

  public enum Backup {
    /// Dropbox
    public static let dropbox = Localized.tr("Localizable", "backup.dropbox")
    /// Google Drive
    public static let googleDrive = Localized.tr("Localizable", "backup.googleDrive")
    /// Account Backup
    public static let header = Localized.tr("Localizable", "backup.header")
    /// iCloud
    public static let iCloud = Localized.tr("Localizable", "backup.iCloud")
    /// SFTP
    public static let sftp = Localized.tr("Localizable", "backup.SFTP")
    /// Back up your account to a cloud storage service, you can restore it along with only your contacts when you reinstall xx Messenger on another device.
    public static let subtitle = Localized.tr("Localizable", "backup.subtitle")
    public enum Config {
      /// Backup now
      public static let backupNow = Localized.tr("Localizable", "backup.config.backupNow")
      /// Content backed up in %@ is encrypted with your passphrase in a brute force resistant manner
      public static func disclaimer(_ p1: Any) -> String {
        return Localized.tr("Localizable", "backup.config.disclaimer", String(describing: p1))
      }
      /// Backup to %@
      public static func frequency(_ p1: Any) -> String {
        return Localized.tr("Localizable", "backup.config.frequency", String(describing: p1))
      }
      /// Backup over
      public static let infrastructure = Localized.tr("Localizable", "backup.config.infrastructure")
      /// LATEST BACKUP
      public static let latestBackup = Localized.tr("Localizable", "backup.config.latestBackup")
      /// Backup settings
      public static let title = Localized.tr("Localizable", "backup.config.title")
    }
    public enum Setup {
      /// Setup your #backup service#.
      public static let title = Localized.tr("Localizable", "backup.setup.title")
    }
  }

  public enum Chat {
    /// Cancel
    public static let cancel = Localized.tr("Localizable", "chat.cancel")
    /// Type your message here...
    public static let placeholder = Localized.tr("Localizable", "chat.placeholder")
    public enum Actions {
      /// Camera
      public static let camera = Localized.tr("Localizable", "chat.actions.camera")
      /// Files
      public static let files = Localized.tr("Localizable", "chat.actions.files")
      /// Gallery
      public static let gallery = Localized.tr("Localizable", "chat.actions.gallery")
      public enum Permission {
        /// Continue
        public static let `continue` = Localized.tr("Localizable", "chat.actions.permission.continue")
        /// Not now
        public static let notnow = Localized.tr("Localizable", "chat.actions.permission.notnow")
        public enum Camera {
          /// To take and send photos, xx messenger needs access to your camera.
          public static let subtitle = Localized.tr("Localizable", "chat.actions.permission.camera.subtitle")
          /// Camera Permission
          public static let title = Localized.tr("Localizable", "chat.actions.permission.camera.title")
        }
        public enum Library {
          /// To attach existing photos, xx messenger needs access to your camera roll / photo library.
          public static let subtitle = Localized.tr("Localizable", "chat.actions.permission.library.subtitle")
          /// Photos Permission
          public static let title = Localized.tr("Localizable", "chat.actions.permission.library.title")
        }
        public enum Microphone {
          /// To record and send audio messages, xx messenger needs access to your microphone.
          public static let subtitle = Localized.tr("Localizable", "chat.actions.permission.microphone.subtitle")
          /// Microphone Permission
          public static let title = Localized.tr("Localizable", "chat.actions.permission.microphone.title")
        }
      }
    }
    public enum BubbleMenu {
      /// Copy
      public static let copy = Localized.tr("Localizable", "chat.bubbleMenu.copy")
      /// Delete
      public static let delete = Localized.tr("Localizable", "chat.bubbleMenu.delete")
      /// Reply
      public static let reply = Localized.tr("Localizable", "chat.bubbleMenu.reply")
      /// Retry
      public static let retry = Localized.tr("Localizable", "chat.bubbleMenu.retry")
      /// Select
      public static let select = Localized.tr("Localizable", "chat.bubbleMenu.select")
    }
    public enum Clear {
      /// Clear
      public static let action = Localized.tr("Localizable", "chat.clear.action")
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "chat.clear.cancel")
      /// This action will delete all stored messages related to this contact and it can’t be undone
      public static let subtitle = Localized.tr("Localizable", "chat.clear.subtitle")
      /// Warning
      public static let title = Localized.tr("Localizable", "chat.clear.title")
    }
    public enum E2e {
      /// You and %@ now have a #quantum-secure#, completely private channel for messaging.
      /// #Say hello#!
      public static func placeholder(_ p1: Any) -> String {
        return Localized.tr("Localizable", "chat.e2e.placeholder", String(describing: p1))
      }
    }
    public enum Menu {
      /// Delete
      /// All
      public static let deleteAll = Localized.tr("Localizable", "chat.menu.deleteAll")
    }
    public enum RetrySheet {
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "chat.retrySheet.cancel")
      /// Delete
      public static let delete = Localized.tr("Localizable", "chat.retrySheet.delete")
      /// Try again
      public static let retry = Localized.tr("Localizable", "chat.retrySheet.retry")
    }
    public enum RoundDrawer {
      /// OK
      public static let action = Localized.tr("Localizable", "chat.roundDrawer.action")
      /// The mix for this message will be available shortly, please check again later.
      public static let title = Localized.tr("Localizable", "chat.roundDrawer.title")
    }
    public enum SheetMenu {
      /// Clear chat
      public static let clear = Localized.tr("Localizable", "chat.sheetMenu.clear")
      /// View contact profile
      public static let details = Localized.tr("Localizable", "chat.sheetMenu.details")
    }
  }

  public enum ChatList {
    /// Go to contacts
    public static let action = Localized.tr("Localizable", "chatList.action")
    /// Start chatting with your contacts
    public static let emptyTitle = Localized.tr("Localizable", "chatList.emptyTitle")
    /// Chats
    public static let title = Localized.tr("Localizable", "chatList.title")
    public enum Dashboard {
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "chatList.dashboard.cancel")
      /// Open
      public static let `open` = Localized.tr("Localizable", "chatList.dashboard.open")
      /// The dashboard will be opened using your default browser
      public static let subtitle = Localized.tr("Localizable", "chatList.dashboard.subtitle")
      /// Do you want to open the dashboard?
      public static let title = Localized.tr("Localizable", "chatList.dashboard.title")
    }
    public enum Delete {
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "chatList.delete.cancel")
      /// Delete
      public static let delete = Localized.tr("Localizable", "chatList.delete.delete")
      /// This action will only delete these messages locally
      public static let subtitle = Localized.tr("Localizable", "chatList.delete.subtitle")
      /// Are you sure you want to delete one or more chats?
      public static let title = Localized.tr("Localizable", "chatList.delete.title")
    }
    public enum DeleteAll {
      /// Delete All Chats
      public static let delete = Localized.tr("Localizable", "chatList.deleteAll.delete")
      /// All chats will be deleted from this phone. However, your contacts and their copies of your chats will remain unchanged. Encrypted copies may remain on the decentralized network for up to three weeks.
      /// 
      /// This will only delete chats locally—they can remain on the network (only decryptable by you) for up to three weeks, and they will also remain on the recipient(s) device(s).
      public static let subtitle = Localized.tr("Localizable", "chatList.deleteAll.subtitle")
      /// Delete All Chats?
      public static let title = Localized.tr("Localizable", "chatList.deleteAll.title")
    }
    public enum DeleteGroup {
      /// Leave group
      public static let action = Localized.tr("Localizable", "chatList.deleteGroup.action")
      /// You will exit this group and you won’t receive any more messages from this group and your group messages will be lost.
      public static let subtitle = Localized.tr("Localizable", "chatList.deleteGroup.subtitle")
      /// Are you sure you want to delete a group?
      public static let title = Localized.tr("Localizable", "chatList.deleteGroup.title")
    }
    public enum Join {
      /// The xx network webpage will be opened using your default browser
      public static let subtitle = Localized.tr("Localizable", "chatList.join.subtitle")
      /// Do you want to open the default browser?
      public static let title = Localized.tr("Localizable", "chatList.join.title")
    }
    public enum Menu {
      /// Delete All
      public static let deleteAll = Localized.tr("Localizable", "chatList.menu.deleteAll")
    }
    public enum NavigationBar {
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "chatList.navigationBar.cancel")
    }
    public enum Traffic {
      /// Not now
      public static let negative = Localized.tr("Localizable", "chatList.traffic.negative")
      /// Enable
      public static let positive = Localized.tr("Localizable", "chatList.traffic.positive")
      /// Hide when you send messages, providing you with extra privacy; This will consume more battery, but you can always turn it off in settings.
      public static let subtitle = Localized.tr("Localizable", "chatList.traffic.subtitle")
      /// Enable Cover Traffic
      public static let title = Localized.tr("Localizable", "chatList.traffic.title")
    }
  }

  public enum Contact {
    /// Edit
    public static let edit = Localized.tr("Localizable", "contact.edit")
    /// Email
    public static let email = Localized.tr("Localizable", "contact.email")
    /// Nickname
    public static let nickname = Localized.tr("Localizable", "contact.nickname")
    /// Phone Number
    public static let phone = Localized.tr("Localizable", "contact.phone")
    /// Username
    public static let username = Localized.tr("Localizable", "contact.username")
    public enum Clear {
      /// Clear
      public static let action = Localized.tr("Localizable", "contact.clear.action")
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "contact.clear.cancel")
      /// This action will delete all stored messages related to this contact and it can’t be undone
      public static let subtitle = Localized.tr("Localizable", "contact.clear.subtitle")
      /// Warning
      public static let title = Localized.tr("Localizable", "contact.clear.title")
    }
    public enum Confirmed {
      /// Clear chat
      public static let clear = Localized.tr("Localizable", "contact.confirmed.clear")
      /// Delete contact
      public static let delete = Localized.tr("Localizable", "contact.confirmed.delete")
      /// Send message
      public static let send = Localized.tr("Localizable", "contact.confirmed.send")
    }
    public enum Delete {
      public enum Drawer {
        /// This is a silent deletion, %@ will not know you deleted them. This action will remove all information on your phone about this user, including your communications. You #cannot undo this step, and cannot re-add them unless they delete you as a connection as well.#
        public static func description(_ p1: Any) -> String {
          return Localized.tr("Localizable", "contact.delete.drawer.description", String(describing: p1))
        }
        /// Delete Connection?
        public static let title = Localized.tr("Localizable", "contact.delete.drawer.title")
      }
      public enum Info {
        /// Delete Connection
        public static let title = Localized.tr("Localizable", "contact.delete.info.title")
      }
    }
    public enum Inprogress {
      /// Your request failed to send
      public static let failed = Localized.tr("Localizable", "contact.inprogress.failed")
      /// Pending
      public static let pending = Localized.tr("Localizable", "contact.inprogress.pending")
      /// Resend
      public static let resend = Localized.tr("Localizable", "contact.inprogress.resend")
    }
    public enum Nickname {
      /// Contact Nickname
      public static let input = Localized.tr("Localizable", "contact.nickname.input")
      /// Nickname can't be empty
      public static let minimum = Localized.tr("Localizable", "contact.nickname.minimum")
      /// Save Contact
      public static let save = Localized.tr("Localizable", "contact.nickname.save")
      /// Create a Contact
      public static let title = Localized.tr("Localizable", "contact.nickname.title")
    }
    public enum Received {
      /// Accept
      public static let accept = Localized.tr("Localizable", "contact.received.accept")
      /// Reject
      public static let reject = Localized.tr("Localizable", "contact.received.reject")
      /// Accept Contact?
      public static let title = Localized.tr("Localizable", "contact.received.title")
    }
    public enum Scanned {
      /// Request
      public static let action = Localized.tr("Localizable", "contact.scanned.action")
      /// Once they've accepted your request, you're ready to message!
      public static let subtitle = Localized.tr("Localizable", "contact.scanned.subtitle")
      /// Request Contact
      public static let title = Localized.tr("Localizable", "contact.scanned.title")
    }
    public enum SendMessage {
      public enum Info {
        /// Messages are sent over the #xx network cMix protocol# ensuring that no one can link the sender and recipient. Furthermore, they are encrypted with quantum-secure, end-to-end encryption, with forward secrecy.
        public static let subtitle = Localized.tr("Localizable", "contact.sendMessage.info.subtitle")
        /// Send Message
        public static let title = Localized.tr("Localizable", "contact.sendMessage.info.title")
      }
    }
    public enum Success {
      /// Keep adding
      public static let keepAdding = Localized.tr("Localizable", "contact.success.keepAdding")
      /// Go to requests
      public static let sentRequests = Localized.tr("Localizable", "contact.success.sentRequests")
    }
  }

  public enum ContactList {
    /// New Group
    public static let newGroup = Localized.tr("Localizable", "contactList.newGroup")
    /// Connections
    public static let title = Localized.tr("Localizable", "contactList.title")
    /// User Search
    public static let userSearch = Localized.tr("Localizable", "contactList.userSearch")
    public enum Empty {
      /// Add contact
      public static let action = Localized.tr("Localizable", "contactList.empty.action")
      /// Add a contact to start messaging
      public static let title = Localized.tr("Localizable", "contactList.empty.title")
    }
  }

  public enum Countries {
    /// Country Code
    public static let title = Localized.tr("Localizable", "countries.title")
  }

  public enum CreateGroup {
    /// Contacts
    public static let contacts = Localized.tr("Localizable", "createGroup.contacts")
    /// Create
    public static let create = Localized.tr("Localizable", "createGroup.create")
    /// Add members #(%@/10)#
    public static func title(_ p1: Any) -> String {
      return Localized.tr("Localizable", "createGroup.title", String(describing: p1))
    }
    public enum Drawer {
      /// Create Group
      public static let action = Localized.tr("Localizable", "createGroup.drawer.action")
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "createGroup.drawer.cancel")
      /// Group Name
      public static let input = Localized.tr("Localizable", "createGroup.drawer.input")
      /// Needs to be 20 chars max or 256 bytes
      public static let maximum = Localized.tr("Localizable", "createGroup.drawer.maximum")
      /// Needs to be at least 4 chars
      public static let minimum = Localized.tr("Localizable", "createGroup.drawer.minimum")
      /// Initial Message
      public static let otherInput = Localized.tr("Localizable", "createGroup.drawer.otherInput")
      /// Say hi to your friends!
      public static let otherPlaceholder = Localized.tr("Localizable", "createGroup.drawer.otherPlaceholder")
      /// Secret Family
      public static let placeholder = Localized.tr("Localizable", "createGroup.drawer.placeholder")
      /// You are about to create a group message with %@ users. The information below will be visible to all members of the group.
      public static func subtitle(_ p1: Any) -> String {
        return Localized.tr("Localizable", "createGroup.drawer.subtitle", String(describing: p1))
      }
      /// Create Group
      public static let title = Localized.tr("Localizable", "createGroup.drawer.title")
    }
  }

  public enum Hud {
    public enum Error {
      /// OK
      public static let action = Localized.tr("Localizable", "hud.error.action")
      /// Error
      public static let title = Localized.tr("Localizable", "hud.error.title")
    }
  }

  public enum Launch {
    public enum Version {
      /// Failed checking app version
      public static let failed = Localized.tr("Localizable", "launch.version.failed")
      public enum Recommended {
        /// Not now
        public static let negative = Localized.tr("Localizable", "launch.version.recommended.negative")
        /// Update
        public static let positive = Localized.tr("Localizable", "launch.version.recommended.positive")
        /// There is a new version available that enhance the current performance and usability.
        public static let title = Localized.tr("Localizable", "launch.version.recommended.title")
      }
      public enum Required {
        /// Okay
        public static let positive = Localized.tr("Localizable", "launch.version.required.positive")
      }
    }
  }

  public enum Menu {
    /// Build %@
    public static func build(_ p1: Any) -> String {
      return Localized.tr("Localizable", "menu.build", String(describing: p1))
    }
    /// Chats
    public static let chats = Localized.tr("Localizable", "menu.chats")
    /// Connections
    public static let contacts = Localized.tr("Localizable", "menu.contacts")
    /// Dashboard
    public static let dashboard = Localized.tr("Localizable", "menu.dashboard")
    /// Profile
    public static let profile = Localized.tr("Localizable", "menu.profile")
    /// Requests
    public static let requests = Localized.tr("Localizable", "menu.requests")
    /// Scan QR
    public static let scan = Localized.tr("Localizable", "menu.scan")
    /// Settings
    public static let settings = Localized.tr("Localizable", "menu.settings")
    /// Hello
    public static let title = Localized.tr("Localizable", "menu.title")
    /// Version %@
    public static func version(_ p1: Any) -> String {
      return Localized.tr("Localizable", "menu.version", String(describing: p1))
    }
    /// View Profile
    public static let viewProfile = Localized.tr("Localizable", "menu.viewProfile")
  }

  public enum Onboarding {
    public enum Email {
      /// Next
      public static let action = Localized.tr("Localizable", "onboarding.email.action")
      /// Email Address
      public static let input = Localized.tr("Localizable", "onboarding.email.input")
      /// Skip. Do not add an email 
      public static let skip = Localized.tr("Localizable", "onboarding.email.skip")
      /// You can add, remove, or edit this email in your profile settings. Adding an email is optional.
      public static let subtitle = Localized.tr("Localizable", "onboarding.email.subtitle")
      /// Add your #email#.
      public static let title = Localized.tr("Localizable", "onboarding.email.title")
      public enum Info {
        /// This email will be shared with our third-party provider, Twilio, to verify your ownership through a confirmation code. However, it will be immediately removed from the xx network’s systems and only a salted hash of the email will be stored in the #User Discovery Service.#
        public static let subtitle = Localized.tr("Localizable", "onboarding.email.info.subtitle")
        /// Your Email
        public static let title = Localized.tr("Localizable", "onboarding.email.info.title")
      }
    }
    public enum EmailConfirmation {
      /// Code
      public static let input = Localized.tr("Localizable", "onboarding.emailConfirmation.input")
      /// Next
      public static let next = Localized.tr("Localizable", "onboarding.emailConfirmation.next")
      /// Resend Code %@
      public static func resend(_ p1: Any) -> String {
        return Localized.tr("Localizable", "onboarding.emailConfirmation.resend", String(describing: p1))
      }
      /// We sent a verification code to %@.
      public static func subtitle(_ p1: Any) -> String {
        return Localized.tr("Localizable", "onboarding.emailConfirmation.subtitle", String(describing: p1))
      }
      /// Please enter the #code# sent to your email.
      public static let title = Localized.tr("Localizable", "onboarding.emailConfirmation.title")
      public enum Info {
        /// xx messenger uses Twilio’s two-factor authentication to prevent someone from fraudulently registering your email on the xx messenger.
        public static let subtitle = Localized.tr("Localizable", "onboarding.emailConfirmation.info.subtitle")
        /// 2-Factor Authentication
        public static let title = Localized.tr("Localizable", "onboarding.emailConfirmation.info.title")
      }
    }
    public enum Phone {
      /// Next
      public static let action = Localized.tr("Localizable", "onboarding.phone.action")
      /// Phone Number
      public static let input = Localized.tr("Localizable", "onboarding.phone.input")
      /// Skip. Do not add a phone number
      public static let skip = Localized.tr("Localizable", "onboarding.phone.skip")
      /// You can add, remove, or edit this phone number in your profile settings. Adding a phone number is optional.
      public static let subtitle = Localized.tr("Localizable", "onboarding.phone.subtitle")
      /// Add your #phone number#.
      public static let title = Localized.tr("Localizable", "onboarding.phone.title")
      public enum Info {
        /// This phone number will be shared with our third-party provider, Twilio, to verify your ownership through a confirmation code. However, it will be immediately removed from the xx network’s systems and only a salted hash of the phone number will be stored in the #User Discovery Service.#
        public static let subtitle = Localized.tr("Localizable", "onboarding.phone.info.subtitle")
        /// Your Phone Number
        public static let title = Localized.tr("Localizable", "onboarding.phone.info.title")
      }
    }
    public enum PhoneConfirmation {
      /// Code
      public static let input = Localized.tr("Localizable", "onboarding.phoneConfirmation.input")
      /// Next
      public static let next = Localized.tr("Localizable", "onboarding.phoneConfirmation.next")
      /// Resend Code %@
      public static func resend(_ p1: Any) -> String {
        return Localized.tr("Localizable", "onboarding.phoneConfirmation.resend", String(describing: p1))
      }
      /// We sent a verification code to %@.
      public static func subtitle(_ p1: Any) -> String {
        return Localized.tr("Localizable", "onboarding.phoneConfirmation.subtitle", String(describing: p1))
      }
      /// Please enter the #code# sent to your phone through #SMS#.
      public static let title = Localized.tr("Localizable", "onboarding.phoneConfirmation.title")
      public enum Info {
        /// xx messenger uses Twilio’s two-factor authentication to prevent someone from fraudulently registering your phone on the xx messenger.
        public static let subtitle = Localized.tr("Localizable", "onboarding.phoneConfirmation.info.subtitle")
        /// 2-Factor Authentication
        public static let title = Localized.tr("Localizable", "onboarding.phoneConfirmation.info.title")
      }
    }
    public enum Start {
      /// Get Started
      public static let action = Localized.tr("Localizable", "onboarding.start.action")
      /// A quantum leap in privacy
      public static let title = Localized.tr("Localizable", "onboarding.start.title")
    }
    public enum Success {
      /// Next
      public static let action = Localized.tr("Localizable", "onboarding.success.action")
      public enum Email {
        /// Your #email# has been successfully #added#.
        public static let title = Localized.tr("Localizable", "onboarding.success.email.title")
      }
      public enum Phone {
        /// Your #phone# has been successfully #added#.
        public static let title = Localized.tr("Localizable", "onboarding.success.phone.title")
      }
    }
    public enum Username {
      /// Username
      public static let input = Localized.tr("Localizable", "onboarding.username.input")
      /// Next
      public static let next = Localized.tr("Localizable", "onboarding.username.next")
      /// Your unique username is the first name your contacts will see in their searches and contact lists. This cannot be changed.
      public static let subtitle = Localized.tr("Localizable", "onboarding.username.subtitle")
      /// Choose your #username#.
      public static let title = Localized.tr("Localizable", "onboarding.username.title")
      public enum Info {
        /// Your chosen username will be registered with the #User Discovery Service# allowing your public keys to be accessible to anyone who knows your username. They will then be able to send a request to create an authenticated channel with you. You will then be able to reject unwanted requests.
        public static let subtitle = Localized.tr("Localizable", "onboarding.username.info.subtitle")
        /// Your Username
        public static let title = Localized.tr("Localizable", "onboarding.username.info.title")
      }
      public enum Restore {
        /// Restore From Backup
        public static let action = Localized.tr("Localizable", "onboarding.username.restore.action")
        /// Already have an account?
        public static let title = Localized.tr("Localizable", "onboarding.username.restore.title")
      }
    }
    public enum Welcome {
      /// Yes, continue
      public static let `continue` = Localized.tr("Localizable", "onboarding.welcome.continue")
      /// No, skip this step
      public static let skip = Localized.tr("Localizable", "onboarding.welcome.skip")
      /// Would you like to register an email or phone number to help other users find your account? If not, you can still be found by your username, or completely off the grid using QR codes.
      public static let subtitle = Localized.tr("Localizable", "onboarding.welcome.subtitle")
      /// %@,
      /// welcome to
      /// #xx network#
      public static func title(_ p1: Any) -> String {
        return Localized.tr("Localizable", "onboarding.welcome.title", String(describing: p1))
      }
      public enum Info {
        /// Registration is completely optional. When registering an email or phone number, they will be evaluated by twilio, a 3rd party partner. Afterwards, salted hashes will be registered in #User Discovery# to allow other uses to search for you using the registered data completely privately.
        public static let subtitle = Localized.tr("Localizable", "onboarding.welcome.info.subtitle")
        /// Welcome
        public static let title = Localized.tr("Localizable", "onboarding.welcome.info.title")
      }
    }
  }

  public enum Profile {
    public enum Code {
      /// Save
      public static let action = Localized.tr("Localizable", "profile.code.action")
      /// Resend Code %@
      public static func resend(_ p1: Any) -> String {
        return Localized.tr("Localizable", "profile.code.resend", String(describing: p1))
      }
      /// Enter the code we just sent to
      /// %@
      public static func subtitle(_ p1: Any) -> String {
        return Localized.tr("Localizable", "profile.code.subtitle", String(describing: p1))
      }
      /// Enter Code
      public static let title = Localized.tr("Localizable", "profile.code.title")
    }
    public enum Delete {
      /// Delete %@
      public static func action(_ p1: Any) -> String {
        return Localized.tr("Localizable", "profile.delete.action", String(describing: p1))
      }
      /// You will no longer be found by this %@. You can add your %@ back later.
      public static func subtitle(_ p1: Any, _ p2: Any) -> String {
        return Localized.tr("Localizable", "profile.delete.subtitle", String(describing: p1), String(describing: p2))
      }
      /// Delete %@?
      public static func title(_ p1: Any) -> String {
        return Localized.tr("Localizable", "profile.delete.title", String(describing: p1))
      }
    }
    public enum Email {
      /// Add email address
      public static let placeholder = Localized.tr("Localizable", "profile.email.placeholder")
      /// Email Address
      public static let title = Localized.tr("Localizable", "profile.email.title")
    }
    public enum EmailScreen {
      /// Save
      public static let action = Localized.tr("Localizable", "profile.emailScreen.action")
      /// Email
      public static let input = Localized.tr("Localizable", "profile.emailScreen.input")
      /// Add Email
      public static let title = Localized.tr("Localizable", "profile.emailScreen.title")
    }
    public enum Phone {
      /// Add phone number
      public static let placeholder = Localized.tr("Localizable", "profile.phone.placeholder")
      /// Phone Number
      public static let title = Localized.tr("Localizable", "profile.phone.title")
    }
    public enum PhoneScreen {
      /// Save
      public static let action = Localized.tr("Localizable", "profile.phoneScreen.action")
      /// Phone Number
      public static let input = Localized.tr("Localizable", "profile.phoneScreen.input")
      /// Add Phone
      public static let title = Localized.tr("Localizable", "profile.phoneScreen.title")
    }
    public enum Photo {
      /// Not now
      public static let cancel = Localized.tr("Localizable", "profile.photo.cancel")
      /// OK
      public static let `continue` = Localized.tr("Localizable", "profile.photo.continue")
      /// This avatar will only be visible to you
      public static let subtitle = Localized.tr("Localizable", "profile.photo.subtitle")
      /// Alert
      public static let title = Localized.tr("Localizable", "profile.photo.title")
    }
  }

  public enum Requests {
    /// Requests
    public static let title = Localized.tr("Localizable", "requests.title")
    public enum Cell {
      /// Retry
      public static let failedRequest = Localized.tr("Localizable", "requests.cell.failedRequest")
      /// Failed to verify
      public static let failedVerification = Localized.tr("Localizable", "requests.cell.failedVerification")
      /// Resend
      public static let requested = Localized.tr("Localizable", "requests.cell.requested")
      /// Resent
      public static let resent = Localized.tr("Localizable", "requests.cell.resent")
      /// Verifying
      public static let verifying = Localized.tr("Localizable", "requests.cell.verifying")
    }
    public enum Confirmations {
      /// Accepted your request
      public static let toaster = Localized.tr("Localizable", "requests.confirmations.toaster")
    }
    public enum Drawer {
      public enum Group {
        /// Accept
        public static let accept = Localized.tr("Localizable", "requests.drawer.group.accept")
        /// Hide Request
        public static let hide = Localized.tr("Localizable", "requests.drawer.group.hide")
        /// GROUP CHAT REQUEST
        public static let title = Localized.tr("Localizable", "requests.drawer.group.title")
        public enum Success {
          /// Later
          public static let later = Localized.tr("Localizable", "requests.drawer.group.success.later")
          /// Go to Chat
          public static let send = Localized.tr("Localizable", "requests.drawer.group.success.send")
          /// You are now part of the group chat. Would you like to check it out?
          public static let subtitle = Localized.tr("Localizable", "requests.drawer.group.success.subtitle")
          /// ACCEPTED
          public static let title = Localized.tr("Localizable", "requests.drawer.group.success.title")
        }
      }
      public enum Single {
        /// Accept and Save
        public static let accept = Localized.tr("Localizable", "requests.drawer.single.accept")
        /// EMAIL ADDRESS
        public static let email = Localized.tr("Localizable", "requests.drawer.single.email")
        /// Hide Request
        public static let hide = Localized.tr("Localizable", "requests.drawer.single.hide")
        /// Edit your new contact’s nickname.
        public static let nickname = Localized.tr("Localizable", "requests.drawer.single.nickname")
        /// PHONE NUMBER
        public static let phone = Localized.tr("Localizable", "requests.drawer.single.phone")
        /// REQUEST FROM
        public static let title = Localized.tr("Localizable", "requests.drawer.single.title")
        public enum Success {
          /// Later
          public static let later = Localized.tr("Localizable", "requests.drawer.single.success.later")
          /// Send a Message
          public static let send = Localized.tr("Localizable", "requests.drawer.single.success.send")
          /// Is now a connection, would you like to send a message?
          public static let subtitle = Localized.tr("Localizable", "requests.drawer.single.success.subtitle")
          /// NEW CONNECTION
          public static let title = Localized.tr("Localizable", "requests.drawer.single.success.title")
        }
      }
    }
    public enum Failed {
      /// There are no failed requests
      public static let empty = Localized.tr("Localizable", "requests.failed.empty")
      /// Failed
      public static let title = Localized.tr("Localizable", "requests.failed.title")
      /// Your contact request to %@ has failed.
      public static func toast(_ p1: Any) -> String {
        return Localized.tr("Localizable", "requests.failed.toast", String(describing: p1))
      }
    }
    public enum Received {
      /// Show hidden requests
      public static let hidden = Localized.tr("Localizable", "requests.received.hidden")
      /// No recent requests received
      public static let placeholder = Localized.tr("Localizable", "requests.received.placeholder")
      /// Received
      public static let title = Localized.tr("Localizable", "requests.received.title")
      public enum Verifying {
        /// OK
        public static let action = Localized.tr("Localizable", "requests.received.verifying.action")
        /// We are working on verifying the request to make sure it is not a spam. Please check again shortly.
        public static let subtitle = Localized.tr("Localizable", "requests.received.verifying.subtitle")
        /// Verifying
        public static let title = Localized.tr("Localizable", "requests.received.verifying.title")
      }
    }
    public enum Sent {
      /// Search for connections
      public static let action = Localized.tr("Localizable", "requests.sent.action")
      /// You haven't sent any requests
      public static let empty = Localized.tr("Localizable", "requests.sent.empty")
      /// Sent
      public static let title = Localized.tr("Localizable", "requests.sent.title")
      public enum Toast {
        /// Request successfully resent to %@
        public static func resent(_ p1: Any) -> String {
          return Localized.tr("Localizable", "requests.sent.toast.resent", String(describing: p1))
        }
      }
    }
  }

  public enum Scan {
    /// Go to contact
    public static let contact = Localized.tr("Localizable", "scan.contact")
    /// Check requests
    public static let requests = Localized.tr("Localizable", "scan.requests")
    /// Sending as
    /// #%@#
    public static func sendingAs(_ p1: Any) -> String {
      return Localized.tr("Localizable", "scan.sendingAs", String(describing: p1))
    }
    /// Go to settings
    public static let settings = Localized.tr("Localizable", "scan.settings")
    public enum Display {
      /// Copied!
      public static let copied = Localized.tr("Localizable", "scan.display.copied")
      /// Tap code to copy
      public static let copy = Localized.tr("Localizable", "scan.display.copy")
      public enum Share {
        /// Add
        public static let add = Localized.tr("Localizable", "scan.display.share.add")
        /// EMAIL ADDRESS
        public static let email = Localized.tr("Localizable", "scan.display.share.email")
        /// ・・・・・・・・・・
        public static let hidden = Localized.tr("Localizable", "scan.display.share.hidden")
        /// Not added
        public static let notAdded = Localized.tr("Localizable", "scan.display.share.notAdded")
        /// PHONE NUMBER
        public static let phone = Localized.tr("Localizable", "scan.display.share.phone")
        /// Select what you'd like to share
        public static let title = Localized.tr("Localizable", "scan.display.share.title")
      }
    }
    public enum Error {
      /// Camera needs permission to be used
      public static let denied = Localized.tr("Localizable", "scan.error.denied")
      /// You've already added 
      /// #%@#
      public static func friends(_ p1: Any) -> String {
        return Localized.tr("Localizable", "scan.error.friends", String(describing: p1))
      }
      /// Something’s gone wrong. Please try again.
      public static let general = Localized.tr("Localizable", "scan.error.general")
      /// Invalid QR code
      public static let invalid = Localized.tr("Localizable", "scan.error.invalid")
      /// This user is already pending in your contact list
      public static let pending = Localized.tr("Localizable", "scan.error.pending")
      /// You already have a request open with this contact.
      public static let requested = Localized.tr("Localizable", "scan.error.requested")
    }
    public enum Info {
      /// Personal Information shared with the QR Code. The recipient will be able to see this info on the profile on their device.
      public static let subtitle = Localized.tr("Localizable", "scan.info.subtitle")
      /// QR Code
      public static let title = Localized.tr("Localizable", "scan.info.title")
    }
    public enum SegmentedControl {
      /// Scan Code
      public static let `left` = Localized.tr("Localizable", "scan.segmentedControl.left")
      /// My Code
      public static let `right` = Localized.tr("Localizable", "scan.segmentedControl.right")
    }
    public enum Status {
      /// Place QR code inside frame to scan
      public static let reading = Localized.tr("Localizable", "scan.status.reading")
      /// Success
      public static let success = Localized.tr("Localizable", "scan.status.success")
    }
  }

  public enum Settings {
    /// Advanced Settings
    public static let advanced = Localized.tr("Localizable", "settings.advanced")
    /// Chat Settings
    public static let chat = Localized.tr("Localizable", "settings.chat")
    /// Delete account
    public static let delete = Localized.tr("Localizable", "settings.delete")
    /// Disclosures
    public static let disclosures = Localized.tr("Localizable", "settings.disclosures")
    /// General Settings
    public static let general = Localized.tr("Localizable", "settings.general")
    /// Privacy policy
    public static let privacyPolicy = Localized.tr("Localizable", "settings.privacyPolicy")
    /// Settings
    public static let title = Localized.tr("Localizable", "settings.title")
    public enum Advanced {
      /// Advanced Settings
      public static let title = Localized.tr("Localizable", "settings.advanced.title")
      public enum AccountBackup {
        /// Account Backup
        public static let title = Localized.tr("Localizable", "settings.advanced.accountBackup.title")
      }
      public enum Crashes {
        /// Automatically sends anonymous reports containing crash data
        public static let description = Localized.tr("Localizable", "settings.advanced.crashes.description")
        /// Enable crash reporting
        public static let title = Localized.tr("Localizable", "settings.advanced.crashes.title")
      }
      public enum Logs {
        /// Record your logs to submit for debugging.
        public static let description = Localized.tr("Localizable", "settings.advanced.logs.description")
        /// Record logs
        public static let title = Localized.tr("Localizable", "settings.advanced.logs.title")
      }
      public enum ShowUsername {
        /// Allow us to show a more detailed push notification
        public static let description = Localized.tr("Localizable", "settings.advanced.showUsername.description")
        /// Rich notifications
        public static let title = Localized.tr("Localizable", "settings.advanced.showUsername.title")
      }
    }
    public enum Biometrics {
      /// Enable unlocking with your device biometrics.
      public static let description = Localized.tr("Localizable", "settings.biometrics.description")
      /// Biometric Authentication
      public static let title = Localized.tr("Localizable", "settings.biometrics.title")
    }
    public enum Delete {
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "settings.delete.cancel")
      /// Confirm Delete
      public static let delete = Localized.tr("Localizable", "settings.delete.delete")
      /// Your username
      public static let input = Localized.tr("Localizable", "settings.delete.input")
      /// A deleted account cannot be recovered. The username associated with this account cannot be reused in the future.
      /// 
      /// To confirm your account deletion, type in your username.
      public static let subtitle = Localized.tr("Localizable", "settings.delete.subtitle")
      /// Delete Account
      public static let title = Localized.tr("Localizable", "settings.delete.title")
      public enum Info {
        /// On deletion, all keys for your account are purged from your phone. This action will not notify your contacts. Your keys and any registered emails or phone numbers are removed from the user discovery system.
        public static let subtitle = Localized.tr("Localizable", "settings.delete.info.subtitle")
        /// Deleting Your Account
        public static let title = Localized.tr("Localizable", "settings.delete.info.title")
      }
    }
    public enum Drawer {
      /// %@ will be opened using your default browser
      public static func subtitle(_ p1: Any) -> String {
        return Localized.tr("Localizable", "settings.drawer.subtitle", String(describing: p1))
      }
      /// Do you want to open %@?
      public static func title(_ p1: Any) -> String {
        return Localized.tr("Localizable", "settings.drawer.title", String(describing: p1))
      }
    }
    public enum HideActiveApps {
      /// Hide screen in recent apps list
      public static let description = Localized.tr("Localizable", "settings.hideActiveApps.description")
      /// Hide Screen
      public static let title = Localized.tr("Localizable", "settings.hideActiveApps.title")
    }
    public enum IcognitoKeyboard {
      /// While using the app, allow keyboard to use activity for predictive text.
      public static let description = Localized.tr("Localizable", "settings.icognitoKeyboard.description")
      /// Predictive Text
      public static let title = Localized.tr("Localizable", "settings.icognitoKeyboard.title")
    }
    public enum InAppNotifications {
      /// Enable local in-app notifications.
      public static let description = Localized.tr("Localizable", "settings.inAppNotifications.description")
      /// In-App Notifications
      public static let title = Localized.tr("Localizable", "settings.inAppNotifications.title")
    }
    public enum InfoDrawer {
      /// Got it
      public static let action = Localized.tr("Localizable", "settings.infoDrawer.action")
      public enum Biometrics {
        /// Biometric authentication is stored through the native system on your phone, not by the xx messenger app. The xx network cannot access your biometric authentication data.
        public static let subtitle = Localized.tr("Localizable", "settings.infoDrawer.biometrics.subtitle")
        /// Biometric Authentication
        public static let title = Localized.tr("Localizable", "settings.infoDrawer.biometrics.title")
      }
      public enum Icognito {
        /// Predictive text is a feature offered by your phone’s operating system. It involves storing entered text within your phone’s operating system and may involve sending it to remote servers. As a result, it may significantly degrade your privacy.
        public static let subtitle = Localized.tr("Localizable", "settings.infoDrawer.icognito.subtitle")
        /// Predictive Text
        public static let title = Localized.tr("Localizable", "settings.infoDrawer.icognito.title")
      }
      public enum Notifications {
        /// Selecting this setting will share your account ID and unique phone identifiers with a notification service run by the xx network team. However, these details are obfuscated via an #ID collision system# when you receive a notification. As a result, both the notifications service and your notifications provider (Firebase on Android, Apple on iOS) cannot tell exactly when you receive a message.
        public static let subtitle = Localized.tr("Localizable", "settings.infoDrawer.notifications.subtitle")
        /// Notifications
        public static let title = Localized.tr("Localizable", "settings.infoDrawer.notifications.title")
      }
      public enum Privacy {
        /// Because xx messenger does not capture your personal data or save your private keys, we will not be able to, at this time, help new users recover their account in case of being locked out, changing devices, etc. Account recovery support that continues to protect your privacy and personal data will be coming soon.
        public static let subtitle = Localized.tr("Localizable", "settings.infoDrawer.privacy.subtitle")
        /// Please note
        public static let title = Localized.tr("Localizable", "settings.infoDrawer.privacy.title")
      }
      public enum Traffic {
        /// Cover Traffic hides when you are sending messages by randomly sending messages to random users.  Other user’s phones will pick up these messages but they will not see them or know you sent them. As a result, it not only hides when you send messages, but helps hide who you are talking to. #Read more about it#
        public static let subtitle = Localized.tr("Localizable", "settings.infoDrawer.traffic.subtitle")
        /// Cover Traffic
        public static let title = Localized.tr("Localizable", "settings.infoDrawer.traffic.title")
      }
    }
    public enum RemoteNotifications {
      /// Enable remote push notifications.
      public static let description = Localized.tr("Localizable", "settings.remoteNotifications.description")
      /// Push Notifications
      public static let title = Localized.tr("Localizable", "settings.remoteNotifications.title")
    }
    public enum Traffic {
      /// Enable cover traffic
      public static let subtitle = Localized.tr("Localizable", "settings.traffic.subtitle")
      /// Cover Traffic
      public static let title = Localized.tr("Localizable", "settings.traffic.title")
    }
  }

  public enum Shared {
    /// Done
    public static let done = Localized.tr("Localizable", "shared.done")
    /// #No internet connection.# Connect to a network to continue receiving messages.
    public static let networkIssue = Localized.tr("Localizable", "shared.networkIssue")
    /// #Your request failed#
    public static let requestFailed = Localized.tr("Localizable", "shared.requestFailed")
    /// Resend
    public static let resend = Localized.tr("Localizable", "shared.resend")
    public enum Search {
      /// Search
      public static let placeholder = Localized.tr("Localizable", "shared.search.placeholder")
    }
    public enum SnackBar {
      /// Connecting to xx network...
      public static let title = Localized.tr("Localizable", "shared.snackBar.title")
    }
  }

  public enum Ud {
    /// There are no users with that %@.
    public static func noneFound(_ p1: Any) -> String {
      return Localized.tr("Localizable", "ud.noneFound", String(describing: p1))
    }
    /// User
    public static let sectionTitle = Localized.tr("Localizable", "ud.sectionTitle")
    /// Search
    public static let title = Localized.tr("Localizable", "ud.title")
    public enum NicknameDrawer {
      /// Save
      public static let save = Localized.tr("Localizable", "ud.nicknameDrawer.save")
      /// Edit your new contact’s nickname so you know who they are.
      public static let subtitle = Localized.tr("Localizable", "ud.nicknameDrawer.subtitle")
      /// Add a nickname
      public static let title = Localized.tr("Localizable", "ud.nicknameDrawer.title")
    }
    public enum Placeholder {
      /// Searching is private by nature. The network cannot identify who a search request came from.
      public static let title = Localized.tr("Localizable", "ud.placeholder.title")
      public enum Drawer {
        /// Got it
        public static let action = Localized.tr("Localizable", "ud.placeholder.drawer.action")
        /// You can search for users by their username, email, or phone number using the xx network’s #Anonymous Data Retrieval protocol# which keeps a user’s identity anonymous while requesting data. All sent requests contain salted hashes of what you are searching for. Raw data on emails, usernames, and phone numbers do not leave your phone.
        public static let subtitle = Localized.tr("Localizable", "ud.placeholder.drawer.subtitle")
        /// Search
        public static let title = Localized.tr("Localizable", "ud.placeholder.drawer.title")
      }
    }
    public enum RequestDrawer {
      /// Cancel
      public static let cancel = Localized.tr("Localizable", "ud.requestDrawer.cancel")
      /// EMAIL ADDRESS
      public static let email = Localized.tr("Localizable", "ud.requestDrawer.email")
      /// PHONE NUMBER
      public static let phone = Localized.tr("Localizable", "ud.requestDrawer.phone")
      /// Send Contact Request
      public static let send = Localized.tr("Localizable", "ud.requestDrawer.send")
      /// Request Contact
      public static let title = Localized.tr("Localizable", "ud.requestDrawer.title")
    }
    public enum Tab {
      /// Email
      public static let email = Localized.tr("Localizable", "ud.tab.email")
      /// Phone
      public static let phone = Localized.tr("Localizable", "ud.tab.phone")
      /// QR Code
      public static let qr = Localized.tr("Localizable", "ud.tab.qr")
      /// Username
      public static let username = Localized.tr("Localizable", "ud.tab.username")
    }
  }

  public enum Validator {
    public enum Code {
      /// Code length should be at least 4 chars
      public static let minimum = Localized.tr("Localizable", "validator.code.minimum")
    }
    public enum Email {
      /// The email provided is invalid
      public static let invalid = Localized.tr("Localizable", "validator.email.invalid")
      /// ^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$
      public static let regex = Localized.tr("Localizable", "validator.email.regex")
    }
    public enum Phone {
      /// Phone length should be maximum 32 chars
      public static let maximum = Localized.tr("Localizable", "validator.phone.maximum")
      /// Phone length should be at least 4 chars
      public static let minimum = Localized.tr("Localizable", "validator.phone.minimum")
      /// This phone format doesn't fit the country
      public static let regexIssue = Localized.tr("Localizable", "validator.phone.regexIssue")
    }
    public enum Username {
      /// Character requirement met
      public static let approved = Localized.tr("Localizable", "validator.username.approved")
      /// Username can't be empty
      public static let empty = Localized.tr("Localizable", "validator.username.empty")
      /// The username provided contains one or more forbidden chars
      public static let invalid = Localized.tr("Localizable", "validator.username.invalid")
      /// Max character limit reached.
      public static let maximum = Localized.tr("Localizable", "validator.username.maximum")
      /// Username must be at least 4 characters
      public static let minimum = Localized.tr("Localizable", "validator.username.minimum")
      /// ^[a-zA-Z0-9][a-zA-Z0-9_\-+@.#]*[a-zA-Z0-9]$
      public static let regex = Localized.tr("Localizable", "validator.username.regex")
      /// Username must start and end with alphanumeric characters
      public static let startEnd = Localized.tr("Localizable", "validator.username.startEnd")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localized {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
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
