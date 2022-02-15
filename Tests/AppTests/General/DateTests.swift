import XCTest

@testable import Shared

final class DateTests: XCTestCase {
    var sut: Date!

    override func setUp() {
        sut = DateFormatter.nonUS.date(from: "1/06/1995 07:00:00")!
    }

    func test_MonthDayFormat() {
        XCTAssertEqual(DateFormatter.monthDay.string(from: sut), "June 1")
    }

    func test_shortTimeFormat() {
        XCTAssertEqual(DateFormatter.shortTime.string(from: sut), "7:00 AM")
    }

    func test_shortDateFormat() {
        XCTAssertEqual(DateFormatter.shortDate.string(from: sut), "6/1/95")
    }
}
