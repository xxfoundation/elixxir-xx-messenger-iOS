import XCTest
@testable import DependencyInjection

final class DependencyPropertyWrapperTests: XCTestCase {
    func testPropertyGetter() {
        struct Context {
            static let container = Container()
            @Dependency(container: container) var property: TestDependencyProtocol
        }
        
        let dependency = TestDependency()
        Context.container.register(dependency as TestDependencyProtocol)
        
        XCTAssert(Context().property === dependency)
    }
}

private protocol TestDependencyProtocol: AnyObject {}

private class TestDependency: TestDependencyProtocol {}
