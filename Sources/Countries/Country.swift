import os
import Foundation

private let logger = Logger(subsystem: "logs_xxmessenger", category: "Country.swift")

public struct Country {
    public var name: String
    public var code: String
    public var flag: String
    public var regex: String
    public var prefix: String
    public var example: String
    public var prefixWithFlag: String { "\(flag) \(prefix)" }

    public static func fromMyPhone() -> Self {
        logger.trace("fromMyPhone()")

        let all = all()

        guard let country = all.filter({ $0.code == Locale.current.regionCode }).first else {
            return all.filter { $0.code == "US" }.first!
        }

        return country
    }

    public static func all() -> [Self] {
        logger.trace("all()")

        guard let url = Bundle.module.url(forResource: "country_codes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let countries = try? JSONDecoder().decode([Country].self, from: data) else {
                  logger.error("Can't handle country codes json")
                  fatalError("Can't handle country codes json")
              }

        return countries
    }

    public static func findFrom(_ number: String) -> Self {
        logger.trace("findFrom: \(number, privacy: .public)()")

        return all().first { country in
            let start = number.index(number.startIndex, offsetBy: number.count - 2)
            let end = number.index(start, offsetBy: number.count - (number.count - 2))

            return country.code == String(number[start ..< end])
        }!
    }
}

extension Country: Hashable {}
extension Country: Equatable {}
extension Country: Decodable {}
