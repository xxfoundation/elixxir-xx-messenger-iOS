@propertyWrapper
public struct Dependency<T> {
    public init(container: Container = .shared, file: StaticString = #file, line: UInt = #line) {
        self.container = container
        self.file = file
        self.line = line
    }

    public var wrappedValue: T {
        do {
            return try container.resolve()
        } catch {
            fatalError(error.localizedDescription, file: file, line: line)
        }
    }

    let container: Container
    let file: StaticString
    let line: UInt
}
