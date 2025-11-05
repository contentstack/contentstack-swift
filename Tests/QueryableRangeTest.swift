//
//  QueryableRangeTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class QueryableRangeTest: XCTestCase {
    
    // MARK: - Int QueryableRange Tests
    
    func testInt_stringValue() {
        let value: Int = 42
        XCTAssertEqual(value.stringValue, "42")
    }
    
    func testInt_negativeValue() {
        let value: Int = -100
        XCTAssertEqual(value.stringValue, "-100")
    }
    
    func testInt_zero() {
        let value: Int = 0
        XCTAssertEqual(value.stringValue, "0")
    }
    
    // MARK: - Bool QueryableRange Tests
    
    func testBool_trueValue() {
        let value: Bool = true
        XCTAssertEqual(value.stringValue, "true")
    }
    
    func testBool_falseValue() {
        let value: Bool = false
        XCTAssertEqual(value.stringValue, "false")
    }
    
    // MARK: - Double QueryableRange Tests
    
    func testDouble_stringValue() {
        let value: Double = 3.14159
        XCTAssertEqual(value.stringValue, "3.14159")
    }
    
    func testDouble_negativeValue() {
        let value: Double = -99.99
        XCTAssertEqual(value.stringValue, "-99.99")
    }
    
    func testDouble_zero() {
        let value: Double = 0.0
        XCTAssertEqual(value.stringValue, "0.0")
    }
    
    func testDouble_largeValue() {
        let value: Double = 1234567.89
        XCTAssertEqual(value.stringValue, "1234567.89")
    }
    
    // MARK: - String QueryableRange Tests
    
    func testString_stringValue() {
        let value: String = "Hello World"
        XCTAssertEqual(value.stringValue, "Hello World")
    }
    
    func testString_emptyString() {
        let value: String = ""
        XCTAssertEqual(value.stringValue, "")
    }
    
    func testString_specialCharacters() {
        let value: String = "test@example.com"
        XCTAssertEqual(value.stringValue, "test@example.com")
    }
    
    // MARK: - Date QueryableRange Tests
    
    func testDate_stringValue() {
        let date = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC
        let stringValue = date.stringValue
        
        // Should be ISO8601 formatted
        XCTAssertFalse(stringValue.isEmpty)
        XCTAssertTrue(stringValue.contains("2021"))
    }
    
    func testDate_currentDate() {
        let date = Date()
        let stringValue = date.stringValue
        
        XCTAssertFalse(stringValue.isEmpty)
    }
    
    // MARK: - QueryableRange isEquals Tests
    
    func testQueryableRange_isEquals_sameInts() {
        let value1: Int = 42
        let value2: Int = 42
        
        XCTAssertTrue(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_differentInts() {
        let value1: Int = 42
        let value2: Int = 100
        
        XCTAssertFalse(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_sameStrings() {
        let value1: String = "test"
        let value2: String = "test"
        
        XCTAssertTrue(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_differentStrings() {
        let value1: String = "test1"
        let value2: String = "test2"
        
        XCTAssertFalse(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_sameBools() {
        let value1: Bool = true
        let value2: Bool = true
        
        XCTAssertTrue(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_differentBools() {
        let value1: Bool = true
        let value2: Bool = false
        
        XCTAssertFalse(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_sameDoubles() {
        let value1: Double = 3.14
        let value2: Double = 3.14
        
        XCTAssertTrue(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_differentDoubles() {
        let value1: Double = 3.14
        let value2: Double = 2.71
        
        XCTAssertFalse(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_differentTypes_intAndDouble() {
        let value1: Int = 42
        let value2: Double = 42.0
        
        // Different types should not be equal even if string values match
        XCTAssertFalse(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_differentTypes_intAndString() {
        let value1: Int = 42
        let value2: String = "42"
        
        // Int requires type matching, so Int vs String should not be equal
        XCTAssertFalse(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_sameDates() {
        let date = Date(timeIntervalSince1970: 1609459200)
        let value1 = date
        let value2 = date
        
        XCTAssertTrue(value1.isEquals(to: value2))
    }
    
    func testQueryableRange_isEquals_differentDates() {
        let value1 = Date(timeIntervalSince1970: 1609459200)
        let value2 = Date(timeIntervalSince1970: 1609545600)
        
        XCTAssertFalse(value1.isEquals(to: value2))
    }
    
    static var allTests = [
        ("testInt_stringValue", testInt_stringValue),
        ("testInt_negativeValue", testInt_negativeValue),
        ("testInt_zero", testInt_zero),
        ("testBool_trueValue", testBool_trueValue),
        ("testBool_falseValue", testBool_falseValue),
        ("testDouble_stringValue", testDouble_stringValue),
        ("testDouble_negativeValue", testDouble_negativeValue),
        ("testDouble_zero", testDouble_zero),
        ("testDouble_largeValue", testDouble_largeValue),
        ("testString_stringValue", testString_stringValue),
        ("testString_emptyString", testString_emptyString),
        ("testString_specialCharacters", testString_specialCharacters),
        ("testDate_stringValue", testDate_stringValue),
        ("testDate_currentDate", testDate_currentDate),
        ("testQueryableRange_isEquals_sameInts", testQueryableRange_isEquals_sameInts),
        ("testQueryableRange_isEquals_differentInts", testQueryableRange_isEquals_differentInts),
        ("testQueryableRange_isEquals_sameStrings", testQueryableRange_isEquals_sameStrings),
        ("testQueryableRange_isEquals_differentStrings", testQueryableRange_isEquals_differentStrings),
        ("testQueryableRange_isEquals_sameBools", testQueryableRange_isEquals_sameBools),
        ("testQueryableRange_isEquals_differentBools", testQueryableRange_isEquals_differentBools),
        ("testQueryableRange_isEquals_sameDoubles", testQueryableRange_isEquals_sameDoubles),
        ("testQueryableRange_isEquals_differentDoubles", testQueryableRange_isEquals_differentDoubles),
        ("testQueryableRange_isEquals_differentTypes_intAndDouble", testQueryableRange_isEquals_differentTypes_intAndDouble),
        ("testQueryableRange_isEquals_differentTypes_intAndString", testQueryableRange_isEquals_differentTypes_intAndString),
        ("testQueryableRange_isEquals_sameDates", testQueryableRange_isEquals_sameDates),
        ("testQueryableRange_isEquals_differentDates", testQueryableRange_isEquals_differentDates)
    ]
}

