public struct SFTPService {
    public var isAuthorized: () -> Bool
    public var downloadMetadata: (@escaping (String) -> Void) -> Void
}

public extension SFTPService {
    static var live = SFTPService(
        isAuthorized: {
            true
        },
        downloadMetadata: { completion in
            completion("MOCK")
        }
    )
}
