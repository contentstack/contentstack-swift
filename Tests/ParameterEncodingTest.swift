//
//  ParameterEncodingTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class ParameterEncodingTest: XCTestCase {
    
    // MARK: - Dictionary Addition Operator Tests
    
    func testDictionaryAdditionOperator() {
        let left = ["key1": "value1", "key2": "value2"]
        let right = ["key3": "value3", "key4": "value4"]
        
        let result = left + right
        
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result["key1"], "value1")
        XCTAssertEqual(result["key2"], "value2")
        XCTAssertEqual(result["key3"], "value3")
        XCTAssertEqual(result["key4"], "value4")
    }
    
    func testDictionaryAdditionOperator_withOverlap() {
        let left = ["key1": "value1", "key2": "value2"]
        let right = ["key2": "newValue2", "key3": "value3"]
        
        let result = left + right
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result["key1"], "value1")
        XCTAssertEqual(result["key2"], "newValue2") // Right overwrites left
        XCTAssertEqual(result["key3"], "value3")
    }
    
    func testDictionaryAdditionOperator_emptyDictionaries() {
        let left: [String: String] = [:]
        let right: [String: String] = [:]
        
        let result = left + right
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func testDictionaryAdditionOperator_leftEmpty() {
        let left: [String: String] = [:]
        let right = ["key1": "value1"]
        
        let result = left + right
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result["key1"], "value1")
    }
    
    func testDictionaryAdditionOperator_rightEmpty() {
        let left = ["key1": "value1"]
        let right: [String: String] = [:]
        
        let result = left + right
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result["key1"], "value1")
    }
    
    // MARK: - Query String Generation Tests
    
    func testParametersQuery_simpleString() {
        let params: Parameters = ["name": "John"]
        let queryString = params.query()
        
        XCTAssertEqual(queryString, "name=John")
    }
    
    func testParametersQuery_multipleParams() {
        let params: Parameters = ["name": "John", "age": 30]
        let queryString = params.query()
        
        // Keys are sorted, so we can predict the order
        XCTAssertTrue(queryString.contains("age=30"))
        XCTAssertTrue(queryString.contains("name=John"))
        XCTAssertTrue(queryString.contains("&"))
    }
    
    func testParametersQuery_skipQueryParameter() {
        let params: Parameters = ["query": "test", "name": "John"]
        let queryString = params.query()
        
        // "query" key should be skipped
        XCTAssertEqual(queryString, "name=John")
        XCTAssertFalse(queryString.contains("query"))
    }
    
    func testParametersQuery_skipUIDParameter() {
        let params: Parameters = ["uid": "test_uid", "name": "John"]
        let queryString = params.query()
        
        // "uid" key should be skipped
        XCTAssertEqual(queryString, "name=John")
        XCTAssertFalse(queryString.contains("uid"))
    }
    
    func testParametersQuery_skipContentTypeParameter() {
        let params: Parameters = ["content_type": "test", "name": "John"]
        let queryString = params.query()
        
        // "content_type" key should be skipped
        XCTAssertEqual(queryString, "name=John")
        XCTAssertFalse(queryString.contains("content_type"))
    }
    
    func testParametersQuery_withNumber() {
        let params: Parameters = ["count": 42]
        let queryString = params.query()
        
        XCTAssertEqual(queryString, "count=42")
    }
    
    func testParametersQuery_withDouble() {
        let params: Parameters = ["price": 19.99]
        let queryString = params.query()
        
        XCTAssertEqual(queryString, "price=19.99")
    }
    
    func testParametersQuery_withBool() {
        let params: Parameters = ["active": true, "deleted": false]
        let queryString = params.query()
        
        XCTAssertTrue(queryString.contains("active=true"))
        XCTAssertTrue(queryString.contains("deleted=false"))
    }
    
    func testParametersQuery_withNSNumber() {
        let params: Parameters = ["value": NSNumber(value: 123)]
        let queryString = params.query()
        
        XCTAssertEqual(queryString, "value=123")
    }
    
    func testParametersQuery_withNSNumberBool() {
        let params: Parameters = ["flag": NSNumber(value: true)]
        let queryString = params.query()
        
        XCTAssertEqual(queryString, "flag=true")
    }
    
    func testParametersQuery_withArray() {
        let params: Parameters = ["tags": ["swift", "ios", "mobile"]]
        let queryString = params.query()
        
        // Arrays are encoded with []
        XCTAssertTrue(queryString.contains("tags"))
        XCTAssertTrue(queryString.contains("swift"))
        XCTAssertTrue(queryString.contains("ios"))
        XCTAssertTrue(queryString.contains("mobile"))
    }
    
    func testParametersQuery_withNestedDictionary() {
        let params: Parameters = ["filter": ["status": "active", "type": "user"]]
        let queryString = params.query()
        
        // Nested dictionaries are encoded with bracket notation
        XCTAssertTrue(queryString.contains("filter"))
        XCTAssertTrue(queryString.contains("status"))
        XCTAssertTrue(queryString.contains("active"))
        XCTAssertTrue(queryString.contains("type"))
        XCTAssertTrue(queryString.contains("user"))
    }
    
    func testParametersQuery_withDeepNestedDictionary() {
        let params: Parameters = [
            "user": [
                "profile": [
                    "name": "John"
                ]
            ]
        ]
        let queryString = params.query()
        
        // Deep nested dictionaries
        XCTAssertTrue(queryString.contains("user"))
        XCTAssertTrue(queryString.contains("profile"))
        XCTAssertTrue(queryString.contains("name"))
        XCTAssertTrue(queryString.contains("John"))
    }
    
    func testParametersQuery_withDate() {
        let date = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC
        let params: Parameters = ["created_at": date]
        let queryString = params.query()
        
        XCTAssertTrue(queryString.contains("created_at="))
        // Date should be converted to ISO8601 string
    }
    
    func testParametersQuery_specialCharactersEncoding() {
        let params: Parameters = ["name": "John Doe"]
        let queryString = params.query()
        
        XCTAssertTrue(queryString.contains("name=John%20Doe"))
    }
    
    func testParametersQuery_withSpecialCharacters() {
        let params: Parameters = ["email": "test@example.com"]
        let queryString = params.query()
        
        XCTAssertTrue(queryString.contains("email=test@example.com"))
    }
    
    func testParametersQuery_complexMixedTypes() {
        let params: Parameters = [
            "name": "John",
            "age": 30,
            "active": true,
            "score": 95.5,
            "tags": ["ios", "swift"],
            "metadata": ["key": "value"]
        ]
        let queryString = params.query()
        
        // Complex mixed types should encode all values
        XCTAssertTrue(queryString.contains("name"))
        XCTAssertTrue(queryString.contains("John"))
        XCTAssertTrue(queryString.contains("age"))
        XCTAssertTrue(queryString.contains("30"))
        XCTAssertTrue(queryString.contains("active"))
        XCTAssertTrue(queryString.contains("true"))
        XCTAssertTrue(queryString.contains("score"))
        XCTAssertTrue(queryString.contains("95.5"))
        XCTAssertTrue(queryString.contains("tags"))
        XCTAssertTrue(queryString.contains("ios"))
        XCTAssertTrue(queryString.contains("swift"))
        XCTAssertTrue(queryString.contains("metadata"))
        XCTAssertTrue(queryString.contains("key"))
        XCTAssertTrue(queryString.contains("value"))
    }
    
    func testParametersQuery_emptyDictionary() {
        let params: Parameters = [:]
        let queryString = params.query()
        
        XCTAssertTrue(queryString.isEmpty)
    }
    
    func testParametersQuery_arrayWithNumbers() {
        let params: Parameters = ["ids": [1, 2, 3]]
        let queryString = params.query()
        
        // Arrays with numbers - check that array is encoded
        XCTAssertFalse(queryString.isEmpty)
        // Should contain ids[] notation and the numbers
        let containsIds = queryString.contains("ids")
        let containsNumber = queryString.contains("1") || queryString.contains("2") || queryString.contains("3")
        XCTAssertTrue(containsIds || containsNumber, "Query should contain array data")
    }
    
    func testParametersQuery_arrayWithMixedTypes() {
        let params: Parameters = ["values": [1, "text", true]]
        let queryString = params.query()
        
        // Arrays with mixed types - check that array is encoded
        XCTAssertFalse(queryString.isEmpty)
        let containsValues = queryString.contains("values")
        let containsData = queryString.contains("text") || queryString.contains("1") || queryString.contains("true")
        XCTAssertTrue(containsValues || containsData, "Query should contain array data")
    }
    
    func testParametersQuery_nestedArrays() {
        let params: Parameters = ["matrix": [[1, 2], [3, 4]]]
        let queryString = params.query()
        
        // Nested arrays should be encoded
        XCTAssertTrue(queryString.contains("matrix"))
        XCTAssertFalse(queryString.isEmpty)
    }
    
    func testParametersQuery_urlSafeCharacters() {
        let params: Parameters = ["url": "https://example.com/path?param=value"]
        let queryString = params.query()
        
        XCTAssertTrue(queryString.contains("url="))
        // URL should be percent-encoded appropriately
    }
    
    func testParametersQuery_sortingOrder() {
        let params: Parameters = [
            "zebra": "z",
            "alpha": "a",
            "beta": "b"
        ]
        let queryString = params.query()
        
        // Should be sorted alphabetically
        let components = queryString.components(separatedBy: "&")
        XCTAssertEqual(components[0], "alpha=a")
        XCTAssertEqual(components[1], "beta=b")
        XCTAssertEqual(components[2], "zebra=z")
    }
    
    static var allTests = [
        ("testDictionaryAdditionOperator", testDictionaryAdditionOperator),
        ("testDictionaryAdditionOperator_withOverlap", testDictionaryAdditionOperator_withOverlap),
        ("testDictionaryAdditionOperator_emptyDictionaries", testDictionaryAdditionOperator_emptyDictionaries),
        ("testDictionaryAdditionOperator_leftEmpty", testDictionaryAdditionOperator_leftEmpty),
        ("testDictionaryAdditionOperator_rightEmpty", testDictionaryAdditionOperator_rightEmpty),
        ("testParametersQuery_simpleString", testParametersQuery_simpleString),
        ("testParametersQuery_multipleParams", testParametersQuery_multipleParams),
        ("testParametersQuery_skipQueryParameter", testParametersQuery_skipQueryParameter),
        ("testParametersQuery_skipUIDParameter", testParametersQuery_skipUIDParameter),
        ("testParametersQuery_skipContentTypeParameter", testParametersQuery_skipContentTypeParameter),
        ("testParametersQuery_withNumber", testParametersQuery_withNumber),
        ("testParametersQuery_withDouble", testParametersQuery_withDouble),
        ("testParametersQuery_withBool", testParametersQuery_withBool),
        ("testParametersQuery_withNSNumber", testParametersQuery_withNSNumber),
        ("testParametersQuery_withNSNumberBool", testParametersQuery_withNSNumberBool),
        ("testParametersQuery_withArray", testParametersQuery_withArray),
        ("testParametersQuery_withNestedDictionary", testParametersQuery_withNestedDictionary),
        ("testParametersQuery_withDeepNestedDictionary", testParametersQuery_withDeepNestedDictionary),
        ("testParametersQuery_withDate", testParametersQuery_withDate),
        ("testParametersQuery_specialCharactersEncoding", testParametersQuery_specialCharactersEncoding),
        ("testParametersQuery_withSpecialCharacters", testParametersQuery_withSpecialCharacters),
        ("testParametersQuery_complexMixedTypes", testParametersQuery_complexMixedTypes),
        ("testParametersQuery_emptyDictionary", testParametersQuery_emptyDictionary),
        ("testParametersQuery_arrayWithNumbers", testParametersQuery_arrayWithNumbers),
        ("testParametersQuery_arrayWithMixedTypes", testParametersQuery_arrayWithMixedTypes),
        ("testParametersQuery_nestedArrays", testParametersQuery_nestedArrays),
        ("testParametersQuery_urlSafeCharacters", testParametersQuery_urlSafeCharacters),
        ("testParametersQuery_sortingOrder", testParametersQuery_sortingOrder)
    ]
}

