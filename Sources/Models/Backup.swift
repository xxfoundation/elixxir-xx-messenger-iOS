import Foundation

public struct BackupModel: Equatable, Codable {
    public var id: String
    public var date: Date
    public var size: Float

    public init(
        id: String,
        date: Date,
        size: Float
    ) {
        self.id = id
        self.date = date
        self.size = size
    }
}
