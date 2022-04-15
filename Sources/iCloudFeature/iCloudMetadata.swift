import Foundation

public struct iCloudMetadata: Equatable {
    public var size: Float
    public var path: String
    public var modifiedDate: Date

    public init(
        path: String,
        size: Float,
        modifiedDate: Date
    ) {
        self.path = path
        self.size = size
        self.modifiedDate = modifiedDate
    }
}
