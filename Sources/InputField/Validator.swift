import Shared
import Foundation
import AppResources

private enum Constants {
    static let codeMinimum = Localized.Validator.Code.minimum

    static let emailRegex = Localized.Validator.Email.regex
    static let emailInvalid = Localized.Validator.Email.invalid

    static let phoneMinimum = Localized.Validator.Phone.minimum
    static let phoneMaximum = Localized.Validator.Phone.maximum
    static let phoneRegexIssue = Localized.Validator.Phone.regexIssue

    static let usernameEmpty = Localized.Validator.Username.empty
    static let usernameRegex = Localized.Validator.Username.regex
    static let usernameMinimum = Localized.Validator.Username.minimum
    static let usernameMaximum = Localized.Validator.Username.maximum
    static let usernameInvalid = Localized.Validator.Username.invalid
    static let usernameApproved = Localized.Validator.Username.approved
    static let usernameStartEndInvalid = Localized.Validator.Username.startEnd
}

public enum ValidationResult {
    case success(String?)
    case failure(String)
}

public struct Validator<T> {
    public var validate: (T) -> ValidationResult
}

public extension Validator where T == (String, String) {
    static var phone: Self {
        Validator { regex, phone -> ValidationResult in
            guard phone.count >= 4 else {
                return .failure(Constants.phoneMinimum)
            }

            guard phone.count <= 30 else {
                return .failure(Constants.phoneMaximum)
            }

            let regularExpression = try? NSRegularExpression(pattern: regex)

            guard let regex = regularExpression, regex.firstMatch(in: phone, options: [], range: phone.fullRange()) != nil else {
                return .failure(Constants.phoneRegexIssue)
            }

            return .success(nil)
        }
    }
}

public extension Validator where T == String {
    static var backupPassphrase: Self {
        Validator { passphrase -> ValidationResult in
            guard passphrase.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8 else {
                return .failure("")
            }

            let regex = try? NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d\\W_]{8,}$")

            guard let regex = regex, regex.firstMatch(in: passphrase, options: [], range: passphrase.fullRange()) != nil else {
                return .failure("")
            }

            return .success(nil)
        }
    }

    static var username: Self {
        Validator { username -> ValidationResult in
            guard username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                return .failure(Constants.usernameEmpty)
            }

            guard let first = username.first,
                  let last = username.last,
                  (first.isLetter || first.isNumber),
                  (last.isLetter || last.isNumber) else {
                return .failure(Constants.usernameStartEndInvalid)
            }

            guard username.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4 else {
                return .failure(Constants.usernameMinimum)
            }

            guard username.trimmingCharacters(in: .whitespacesAndNewlines).count <= 32 else {
                return .failure(Constants.usernameMaximum)
            }

            let regex = try? NSRegularExpression(pattern: Constants.usernameRegex)

            guard let regex = regex, regex.firstMatch(in: username, options: [], range: username.fullRange()) != nil else {
                return .failure(Constants.usernameInvalid)
            }

            return .success(Constants.usernameApproved)
        }
    }

    static var email: Self {
        Validator { string -> ValidationResult in
            let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector?.matches(in: string, options: [], range: string.fullRange())

            guard let match = matches?.first,
                  matches?.count == 1,
                  match.url?.scheme == "mailto",
                  match.range == string.fullRange() else { return .failure(Constants.emailInvalid) }

            return .success(nil)
        }
    }

    static var code: Self {
        Validator { code -> ValidationResult in
            guard code.count >= 4 else {
                return .failure(Constants.codeMinimum)
            }

            return .success(nil)
        }
    }
}

private extension String {
    func fullRange() -> NSRange {
        NSRange(self.startIndex..., in: self)
    }
}
