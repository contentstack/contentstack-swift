//
//  DateTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import XCTest
@testable import ContentstackSwift
class DateTest: XCTestCase {

    func testDateFormatter_withMultipleDateFormat() {
        let decoder = JSONDecoder.dateDecodingStrategy()
        let datesJSON = """
        [
            "2020-03-01T05:25:20.817Z",
            "2020-03-01T17:25:20.817Z",
            "2020-03-03",
            "2020-03-04T00:00",
            "2020-03-07T10:00+04:00",
            "2020-03-07T10:00-04:00"
        ]
        """.data(using: .utf8)!

        do {
            let dates = try decoder.decode([Date].self, from: datesJSON)
            XCTAssertEqual(dates[0].iso8601String, "2020-03-01T05:25:20Z")
            XCTAssertEqual(dates[1].iso8601String, "2020-03-01T17:25:20Z")
            XCTAssertEqual(dates[2].iso8601String, "2020-03-03T00:00:00Z")
            XCTAssertEqual(dates[3].iso8601String, "2020-03-04T00:00:00Z")
            XCTAssertEqual(dates[4].iso8601String, "2020-03-07T06:00:00Z")
            XCTAssertEqual(dates[5].iso8601String, "2020-03-07T14:00:00Z")
        } catch {}
    }

    func testDatefromString_ReturnDate() {
        let dateString = "2020-03-01T17:25:20Z"
        let date = dateString.iso8601StringDate
        XCTAssertEqual(date?.iso8601String, "2020-03-01T17:25:20Z")
    }

    static var allTests = [
        ("testDateFormatter_withMultipleDateFormat",
         testDateFormatter_withMultipleDateFormat),
        ("testDatefromString_ReturnDate", testDatefromString_ReturnDate)
    ]
}
