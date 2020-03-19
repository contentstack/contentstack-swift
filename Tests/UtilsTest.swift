//
//  UtilsTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import XCTest
@testable import Contentstack
class UtilsTest: XCTestCase {
    func testDictionary_QueryParams_toString() {
        let query = ["query": ["test": 1]]
        XCTAssertEqual(query.jsonString, "{\n  \"query\" : {\n    \"test\" : 1\n  }\n}")
    }

    static var allTests = [
           ("testDictionary_QueryParams_toString",
            testDictionary_QueryParams_toString)
       ]
}
