import GoogleAPIClientForREST_Drive

public struct GoogleDriveMetadata: Equatable {
    public var size: Float
    public var identifier: String
    public var modifiedDate: Date

    public init(
        size: Float,
        identifier: String,
        modifiedDate: Date
    ) {
        self.size = size
        self.identifier = identifier
        self.modifiedDate = modifiedDate
    }
}

extension GoogleDriveMetadata {
    init?(withDriveFile file: GTLRDrive_File) {
        guard let size = file.size?.floatValue,
              let identifier = file.identifier,
              let modifiedDate = file.modifiedTime?.date else { return nil }

        self.init(size: size, identifier: identifier, modifiedDate: modifiedDate)
    }
}
