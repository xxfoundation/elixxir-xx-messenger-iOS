import Quick
import Nimble
import Defaults
import Foundation
import DependencyInjection

@testable import Theme

final class ThemeTests: QuickSpec {
    override func spec() {
        context("init") {
            var sut: ThemeController!
            var dictionary: NSMutableDictionary!

            beforeEach {
                dictionary = .init()

                DependencyInjection.Container.shared
                    .register(KeyObjectStore.mock(dictionary: dictionary))

                sut = ThemeController()
            }

            afterEach {
                dictionary = nil
            }

            it("should load .system a.k.a 0 from defaults") {
                let theme = dictionary.value(forKey: Key.theme.rawValue) as? Int
                expect(theme).to(equal(0))
            }

            context("when changing theme") {
                beforeEach {
                    sut.theme.send(.dark)
                }

                it("should save .dark") {
                    let theme = dictionary.value(forKey: Key.theme.rawValue) as? Int
                    expect(theme).to(equal(1))
                }
            }
        }
    }
}
