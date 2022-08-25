import Foundation

public struct ReportingStatusIsOptional {
    public var get: () -> Bool
}

extension ReportingStatusIsOptional {
    public static func live(
        plist url: URL = Bundle.main.url(forResource: "Info", withExtension: "plist")!
    ) -> ReportingStatusIsOptional {
        ReportingStatusIsOptional {
            struct Plist: Decodable {
                let isReportingOptional: Bool
            }

            guard let data = try? Data(contentsOf: url),
                  let infoPlist = try? PropertyListDecoder().decode(Plist.self, from: data) else {
                return true
            }

            return infoPlist.isReportingOptional
        }
    }
}
