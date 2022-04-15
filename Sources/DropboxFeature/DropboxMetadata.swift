import Foundation
import SwiftyDropbox

public struct DropboxMetadata: Equatable {
    public var size: Float
    public var path: String
    public var modifiedDate: Date

    public init(
        size: Float,
        path: String,
        modifiedDate: Date
    ) {
        self.size = size
        self.path = path
        self.modifiedDate = modifiedDate
    }
}
