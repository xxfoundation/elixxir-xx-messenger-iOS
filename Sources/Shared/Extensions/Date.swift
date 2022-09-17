import Foundation

public extension Date {
    func asDayOfMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "d MMMM",
            options: 0,
            locale: Locale(identifier: "en_US")
        )

        return formatter.string(from: self)
    }

    func asHoursAndMinutes() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    func asRelativeFromNow() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.string(for: self) ?? ""
    }

    func backupStyle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMM d, YYYY - h:mm",
            options: 0,
            locale: Locale(identifier: "en_US")
        )

        return formatter.string(from: self)
    }

    static var asTimestamp: Int {
        Int(Date().timeIntervalSince1970).toNano()
    }

    static func fromTimestamp(_ timestamp: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp.nanoToSeconds()))
    }

    static func fromMSTimestamp(_ timestampMS: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestampMS) / 1000)
    }
}

private extension Int {
    func nanoToSeconds() -> Int {
        self / 1000000000
    }

    func toNano() -> Int {
        self * 1000000000
    }
}
