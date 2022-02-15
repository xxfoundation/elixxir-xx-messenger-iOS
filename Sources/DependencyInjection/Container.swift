public final class Container {
    public static let shared = Container()

    public init() {}

    public func register<T>(_ dependency: T) {
        dependencies[key(for: T.self)] = dependency
    }

    public func unregister<T>(_ dependencyType: T.Type) {
        dependencies.removeValue(forKey: String(describing: dependencyType))
    }

    public func resolve<T>() throws -> T {
        let key = self.key(for: T.self)
        guard let dependency = dependencies[key] as? T else {
            throw UnregisteredDependencyError(type: key)
        }
        return dependency
    }

    var dependencies = [String: Any]()

    func key<T>(for dependencyType: T.Type) -> String {
        String(describing: dependencyType)
    }
}
