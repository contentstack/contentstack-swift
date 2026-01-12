//
//  QueryOperationTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class QueryOperationTest: XCTestCase {
    
    var stack: Stack!
    var query: Query!
    
    override func setUp() {
        super.setUp()
        // file deepcode ignore NoHardcodedCredentials/test: <please specify a reason of ignoring this>
        stack = Contentstack.stack(apiKey: "test_api_key",
                                   deliveryToken: "test_token",
                                   environment: "test")
        query = stack.contentType(uid: "test_content_type").entry().query()
    }
    
    // MARK: - Query.Operator Tests
    
    func testQueryOperator_and() {
        let query1 = stack.contentType(uid: "test").entry().query()
        query1.queryParameter = ["field1": "value1"]
        
        let query2 = stack.contentType(uid: "test").entry().query()
        query2.queryParameter = ["field2": "value2"]
        
        let andOperator = Query.Operator.and([query1, query2])
        
        XCTAssertEqual(andOperator.string, "$and")
        XCTAssertEqual(andOperator.value.count, 2)
    }
    
    func testQueryOperator_or() {
        let query1 = stack.contentType(uid: "test").entry().query()
        query1.queryParameter = ["field1": "value1"]
        
        let query2 = stack.contentType(uid: "test").entry().query()
        query2.queryParameter = ["field2": "value2"]
        
        let orOperator = Query.Operator.or([query1, query2])
        
        XCTAssertEqual(orOperator.string, "$or")
        XCTAssertEqual(orOperator.value.count, 2)
    }
    
    func testQueryOperator_and_multipleQueries() {
        let queries = (0..<5).map { _ in
            let q = stack.contentType(uid: "test").entry().query()
            q.queryParameter = ["test": "value"]
            return q
        }
        
        let andOperator = Query.Operator.and(queries)
        
        XCTAssertEqual(andOperator.value.count, 5)
    }
    
    // MARK: - Query.Reference Tests
    
    func testQueryReference_include() {
        let refQuery = stack.contentType(uid: "test").entry().query()
        refQuery.queryParameter = ["uid": "test_uid"]
        
        let reference = Query.Reference.include(refQuery)
        
        XCTAssertEqual(reference.string, "$in")
        XCTAssertNotNil(reference.value)
        XCTAssertNotNil(reference.query)
    }
    
    func testQueryReference_notInclude() {
        let refQuery = stack.contentType(uid: "test").entry().query()
        refQuery.queryParameter = ["uid": "test_uid"]
        
        let reference = Query.Reference.notInclude(refQuery)
        
        XCTAssertEqual(reference.string, "$nin")
        XCTAssertNotNil(reference.value)
        XCTAssertNotNil(reference.query)
    }
    
    // MARK: - Query.Operation Tests
    
    func testQueryOperation_equals_string() {
        let operation = Query.Operation.equals("test_value")
        
        XCTAssertEqual(operation.string, "")
        if let value = operation.value as? String {
            XCTAssertEqual(value, "test_value")
        } else {
            XCTFail("Value should be a string")
        }
    }
    
    func testQueryOperation_equals_int() {
        let operation = Query.Operation.equals(42)
        
        if let value = operation.value as? Int {
            XCTAssertEqual(value, 42)
        } else {
            XCTFail("Value should be an int")
        }
    }
    
    func testQueryOperation_equals_double() {
        let operation = Query.Operation.equals(3.14)
        
        if let value = operation.value as? Double {
            XCTAssertEqual(value, 3.14, accuracy: 0.001)
        } else {
            XCTFail("Value should be a double")
        }
    }
    
    func testQueryOperation_equals_bool() {
        let operation = Query.Operation.equals(true)
        
        if let value = operation.value as? Bool {
            XCTAssertTrue(value)
        } else {
            XCTFail("Value should be a bool")
        }
    }
    
    func testQueryOperation_notEquals() {
        let operation = Query.Operation.notEquals("test_value")
        
        XCTAssertEqual(operation.string, "$ne")
        if let value = operation.value as? String {
            XCTAssertEqual(value, "test_value")
        }
    }
    
    func testQueryOperation_notEquals_int() {
        let operation = Query.Operation.notEquals(100)
        
        XCTAssertEqual(operation.string, "$ne")
        if let value = operation.value as? Int {
            XCTAssertEqual(value, 100)
        }
    }
    
    func testQueryOperation_includes() {
        let operation = Query.Operation.includes(["tag1", "tag2", "tag3"])
        
        XCTAssertEqual(operation.string, "$in")
    }
    
    func testQueryOperation_excludes() {
        let operation = Query.Operation.excludes(["tag1", "tag2"])
        
        XCTAssertEqual(operation.string, "$nin")
    }
    
    func testQueryOperation_isLessThan_int() {
        let operation = Query.Operation.isLessThan(100)
        
        XCTAssertEqual(operation.string, "$lt")
        if let value = operation.value as? Int {
            XCTAssertEqual(value, 100)
        }
    }
    
    func testQueryOperation_isLessThan_string() {
        let operation = Query.Operation.isLessThan("z")
        
        XCTAssertEqual(operation.string, "$lt")
        if let value = operation.value as? String {
            XCTAssertEqual(value, "z")
        }
    }
    
    func testQueryOperation_isLessThanOrEqual() {
        let operation = Query.Operation.isLessThanOrEqual(50)
        
        XCTAssertEqual(operation.string, "$lte")
        if let value = operation.value as? Int {
            XCTAssertEqual(value, 50)
        }
    }
    
    func testQueryOperation_isGreaterThan() {
        let operation = Query.Operation.isGreaterThan(10)
        
        XCTAssertEqual(operation.string, "$gt")
        if let value = operation.value as? Int {
            XCTAssertEqual(value, 10)
        }
    }
    
    func testQueryOperation_isGreaterThanOrEqual() {
        let operation = Query.Operation.isGreaterThanOrEqual(25)
        
        XCTAssertEqual(operation.string, "$gte")
        if let value = operation.value as? Int {
            XCTAssertEqual(value, 25)
        }
    }
    
    func testQueryOperation_exists_true() {
        let operation = Query.Operation.exists(true)
        
        XCTAssertEqual(operation.string, "$exists")
        if let value = operation.value as? Bool {
            XCTAssertTrue(value)
        }
    }
    
    func testQueryOperation_exists_false() {
        let operation = Query.Operation.exists(false)
        
        XCTAssertEqual(operation.string, "$exists")
        if let value = operation.value as? Bool {
            XCTAssertFalse(value)
        }
    }
    
    func testQueryOperation_matches() {
        let operation = Query.Operation.matches("^test.*")
        
        XCTAssertEqual(operation.string, "$regex")
        if let value = operation.value as? String {
            XCTAssertEqual(value, "^test.*")
        }
    }
    
    func testQueryOperation_eqBelow() {
        let operation = Query.Operation.eqBelow("taxonomy_uid")
        
        XCTAssertEqual(operation.string, "$eq_below")
        if let value = operation.value as? String {
            XCTAssertEqual(value, "taxonomy_uid")
        }
    }
    
    func testQueryOperation_below() {
        let operation = Query.Operation.below("taxonomy_uid")
        
        XCTAssertEqual(operation.string, "$below")
        if let value = operation.value as? String {
            XCTAssertEqual(value, "taxonomy_uid")
        }
    }
    
    func testQueryOperation_eqAbove() {
        let operation = Query.Operation.eqAbove("taxonomy_uid")
        
        XCTAssertEqual(operation.string, "$eq_above")
        if let value = operation.value as? String {
            XCTAssertEqual(value, "taxonomy_uid")
        }
    }
    
    func testQueryOperation_above() {
        let operation = Query.Operation.above("taxonomy_uid")
        
        XCTAssertEqual(operation.string, "$above")
        if let value = operation.value as? String {
            XCTAssertEqual(value, "taxonomy_uid")
        }
    }
    
    func testQueryOperation_query_equals() {
        let operation = Query.Operation.equals("test")
        
        if let query = operation.query as? String {
            XCTAssertEqual(query, "test")
        }
    }
    
    func testQueryOperation_query_notEquals() {
        let operation = Query.Operation.notEquals("test")
        
        if let query = operation.query as? [String: Any] {
            XCTAssertNotNil(query["$ne"])
        }
    }
    
    func testQueryOperation_query_complexOperation() {
        let operation = Query.Operation.isGreaterThan(10)
        
        if let query = operation.query as? [String: Any] {
            XCTAssertNotNil(query["$gt"])
        }
    }
    
    static var allTests = [
        ("testQueryOperator_and", testQueryOperator_and),
        ("testQueryOperator_or", testQueryOperator_or),
        ("testQueryOperator_and_multipleQueries", testQueryOperator_and_multipleQueries),
        ("testQueryReference_include", testQueryReference_include),
        ("testQueryReference_notInclude", testQueryReference_notInclude),
        ("testQueryOperation_equals_string", testQueryOperation_equals_string),
        ("testQueryOperation_equals_int", testQueryOperation_equals_int),
        ("testQueryOperation_equals_double", testQueryOperation_equals_double),
        ("testQueryOperation_equals_bool", testQueryOperation_equals_bool),
        ("testQueryOperation_notEquals", testQueryOperation_notEquals),
        ("testQueryOperation_notEquals_int", testQueryOperation_notEquals_int),
        ("testQueryOperation_includes", testQueryOperation_includes),
        ("testQueryOperation_excludes", testQueryOperation_excludes),
        ("testQueryOperation_isLessThan_int", testQueryOperation_isLessThan_int),
        ("testQueryOperation_isLessThan_string", testQueryOperation_isLessThan_string),
        ("testQueryOperation_isLessThanOrEqual", testQueryOperation_isLessThanOrEqual),
        ("testQueryOperation_isGreaterThan", testQueryOperation_isGreaterThan),
        ("testQueryOperation_isGreaterThanOrEqual", testQueryOperation_isGreaterThanOrEqual),
        ("testQueryOperation_exists_true", testQueryOperation_exists_true),
        ("testQueryOperation_exists_false", testQueryOperation_exists_false),
        ("testQueryOperation_matches", testQueryOperation_matches),
        ("testQueryOperation_eqBelow", testQueryOperation_eqBelow),
        ("testQueryOperation_below", testQueryOperation_below),
        ("testQueryOperation_eqAbove", testQueryOperation_eqAbove),
        ("testQueryOperation_above", testQueryOperation_above),
        ("testQueryOperation_query_equals", testQueryOperation_query_equals),
        ("testQueryOperation_query_notEquals", testQueryOperation_query_notEquals),
        ("testQueryOperation_query_complexOperation", testQueryOperation_query_complexOperation)
    ]
}

