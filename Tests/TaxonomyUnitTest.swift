//
//  TaxonomyUnitTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class TaxonomyUnitTest: XCTestCase {
    
    var stack: Stack!
    var taxonomy: Taxonomy!
    
    override func setUp() {
        super.setUp()
        stack = makeStackSut()
        taxonomy = stack.taxonomy()
    }
    
    override func tearDown() {
        taxonomy = nil
        stack = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testTaxonomy_initialization() {
        XCTAssertNotNil(taxonomy)
        XCTAssertNotNil(taxonomy.stack)
    }
    
    func testTaxonomy_defaultCachePolicy() {
        XCTAssertEqual(taxonomy.cachePolicy, .networkOnly)
    }
    
    func testTaxonomy_defaultParameters() {
        XCTAssertTrue(taxonomy.parameters.isEmpty)
    }
    
    func testTaxonomy_defaultHeaders() {
        XCTAssertTrue(taxonomy.headers.isEmpty)
    }
    
    func testTaxonomy_defaultQueryParameter() {
        XCTAssertTrue(taxonomy.queryParameter.isEmpty)
    }
    
    func testTaxonomy_defaultUID() {
        XCTAssertNil(taxonomy.uid)
    }
    
    // MARK: - Query Tests
    
    func testTaxonomy_query() {
        let query = taxonomy.query()
        
        XCTAssertNotNil(query)
        XCTAssertEqual(query.cachePolicy, .networkOnly)
    }
    
    func testTaxonomy_query_inheritsStack() {
        let query = taxonomy.query()
        
        XCTAssertEqual(query.stack.apiKey, stack.apiKey)
    }
    
    // MARK: - Header Tests
    
    func testTaxonomy_addHeader() {
        let taxonomy = self.taxonomy.addValue("test_value", forHTTPHeaderField: "X-Custom-Header")
        
        XCTAssertEqual(taxonomy.headers["X-Custom-Header"], "test_value")
    }
    
    func testTaxonomy_addMultipleHeaders() {
        let taxonomy = self.taxonomy
            .addValue("value1", forHTTPHeaderField: "Header1")
            .addValue("value2", forHTTPHeaderField: "Header2")
            .addValue("value3", forHTTPHeaderField: "Header3")
        
        XCTAssertEqual(taxonomy.headers.count, 3)
        XCTAssertEqual(taxonomy.headers["Header1"], "value1")
        XCTAssertEqual(taxonomy.headers["Header2"], "value2")
        XCTAssertEqual(taxonomy.headers["Header3"], "value3")
    }
    
    func testTaxonomy_overwriteHeader() {
        let taxonomy = self.taxonomy
            .addValue("old_value", forHTTPHeaderField: "X-Test")
            .addValue("new_value", forHTTPHeaderField: "X-Test")
        
        XCTAssertEqual(taxonomy.headers["X-Test"], "new_value")
    }
    
    // MARK: - Cache Policy Tests
    
    func testTaxonomy_cachePolicyModification() {
        taxonomy.cachePolicy = .cacheOnly
        
        XCTAssertEqual(taxonomy.cachePolicy, .cacheOnly)
    }
    
    func testTaxonomy_cachePolicyTypes() {
        let policies: [CachePolicy] = [
            .networkOnly,
            .cacheOnly,
            .cacheElseNetwork,
            .networkElseCache,
            .cacheThenNetwork
        ]
        
        for policy in policies {
            taxonomy.cachePolicy = policy
            XCTAssertEqual(taxonomy.cachePolicy, policy)
        }
    }
    
    // MARK: - Parameters Tests
    
    func testTaxonomy_setParameters() {
        taxonomy.parameters = ["key": "value"]
        
        XCTAssertEqual(taxonomy.parameters.count, 1)
        XCTAssertEqual(taxonomy.parameters["key"] as? String, "value")
    }
    
    func testTaxonomy_setQueryParameters() {
        taxonomy.queryParameter = ["query_key": "query_value"]
        
        XCTAssertEqual(taxonomy.queryParameter.count, 1)
        XCTAssertEqual(taxonomy.queryParameter["query_key"] as? String, "query_value")
    }
    
    static var allTests = [
        ("testTaxonomy_initialization", testTaxonomy_initialization),
        ("testTaxonomy_defaultCachePolicy", testTaxonomy_defaultCachePolicy),
        ("testTaxonomy_defaultParameters", testTaxonomy_defaultParameters),
        ("testTaxonomy_defaultHeaders", testTaxonomy_defaultHeaders),
        ("testTaxonomy_defaultQueryParameter", testTaxonomy_defaultQueryParameter),
        ("testTaxonomy_defaultUID", testTaxonomy_defaultUID),
        ("testTaxonomy_query", testTaxonomy_query),
        ("testTaxonomy_query_inheritsStack", testTaxonomy_query_inheritsStack),
        ("testTaxonomy_addHeader", testTaxonomy_addHeader),
        ("testTaxonomy_addMultipleHeaders", testTaxonomy_addMultipleHeaders),
        ("testTaxonomy_overwriteHeader", testTaxonomy_overwriteHeader),
        ("testTaxonomy_cachePolicyModification", testTaxonomy_cachePolicyModification),
        ("testTaxonomy_cachePolicyTypes", testTaxonomy_cachePolicyTypes),
        ("testTaxonomy_setParameters", testTaxonomy_setParameters),
        ("testTaxonomy_setQueryParameters", testTaxonomy_setQueryParameters)
    ]
}

