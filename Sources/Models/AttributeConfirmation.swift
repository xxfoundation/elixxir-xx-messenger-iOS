public struct AttributeConfirmation: Equatable {
    public var content: String
    public var isEmail: Bool = false
    public var confirmationId: String?

    public init(
        content: String,
        isEmail: Bool = false,
        confirmationId: String? = nil
    ) {
        self.content = content
        self.isEmail = isEmail
        self.confirmationId = confirmationId
    }
}
