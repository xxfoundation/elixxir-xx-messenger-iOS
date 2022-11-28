import XCTest

@testable import Defaults

final class KeyObjectSpec: XCTestCase {

  func testGetCachedValue() {
    var didSetObject: Any?
    var didSetObjectForKey: String?

    let sut = KeyObjectStore(
      objectForKey: { _ in fatalError() },
      setObjectForKey: { object, key in
        didSetObject = object
        didSetObjectForKey = key
      }, removeObjectForKey: { _ in fatalError() }
    )

    DI.Container.shared.register(sut)

    @KeyObject(.email, defaultValue: "1234") var email: String

    email = "5678"
    assert(didSetObject as! String == "5678")
    assert(didSetObjectForKey == Key.email.rawValue)
  }

  func testGetDefaultValue() {
    var didGetObjectForKey: String?

    let sut = KeyObjectStore(
      objectForKey: { didGetObjectForKey = $0 },
      setObjectForKey: { _,_ in fatalError() },
      removeObjectForKey: { _ in fatalError() }
    )

    DI.Container.shared.register(sut)

    let defaultValue = "1234"
    @KeyObject(.email, defaultValue: defaultValue) var email: String

    assert(email == defaultValue)
    assert(didGetObjectForKey == Key.email.rawValue)
  }

  func testSetValue() {
    var didSetObject: Any?
    var didSetObjectForKey: String?

    let sut = KeyObjectStore(
      objectForKey: { _ in fatalError() },
      setObjectForKey: { object, key in
        didSetObject = object
        didSetObjectForKey = key
      }, removeObjectForKey: { _ in fatalError() }
    )

    DI.Container.shared.register(sut)

    @KeyObject(.phone, defaultValue: "1234") var phone: String
    phone = "5678"

    assert(didSetObject as! String == "5678")
    assert(didSetObjectForKey == Key.phone.rawValue)
  }

  func testRemovingValue() {
    var didRemoveObjectForKey: String?

    let sut = KeyObjectStore(
      objectForKey: { _ in fatalError() },
      setObjectForKey: { _,_ in fatalError() },
      removeObjectForKey: { didRemoveObjectForKey = $0 }
    )

    DI.Container.shared.register(sut)

    @KeyObject(.phone, defaultValue: "1234") var phone: String?
    phone = nil

    assert(didRemoveObjectForKey == Key.phone.rawValue)
  }
}
