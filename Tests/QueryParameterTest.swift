//
//  QueryParameterTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class QueryParameterTest: XCTestCase {
    
    // MARK: - Query.Include Tests
    
    func testQueryInclude_count() {
        let include = Query.Include.count
        XCTAssertEqual(include.rawValue, 1)
    }
    
    func testQueryInclude_unpublished() {
        let include = Query.Include.unpublished
        XCTAssertEqual(include.rawValue, 2)
    }
    
    func testQueryInclude_contentType() {
        let include = Query.Include.contentType
        XCTAssertEqual(include.rawValue, 4)
    }
    
    func testQueryInclude_globalField() {
        let include = Query.Include.globalField
        XCTAssertEqual(include.rawValue, 8)
    }
    
    func testQueryInclude_refContentTypeUID() {
        let include = Query.Include.refContentTypeUID
        XCTAssertEqual(include.rawValue, 16)
    }
    
    func testQueryInclude_fallback() {
        let include = Query.Include.fallback
        XCTAssertEqual(include.rawValue, 32)
    }
    
    func testQueryInclude_embeddedItems() {
        let include = Query.Include.embeddedItems
        XCTAssertEqual(include.rawValue, 64)
    }
    
    func testQueryInclude_metadata() {
        let include = Query.Include.metadata
        XCTAssertEqual(include.rawValue, 128)
    }
    
    func testQueryInclude_all() {
        let all = Query.Include.all
        XCTAssertTrue(all.contains(.count))
        XCTAssertTrue(all.contains(.unpublished))
        XCTAssertTrue(all.contains(.contentType))
        XCTAssertTrue(all.contains(.globalField))
        XCTAssertTrue(all.contains(.refContentTypeUID))
        XCTAssertTrue(all.contains(.fallback))
        XCTAssertTrue(all.contains(.embeddedItems))
        XCTAssertTrue(all.contains(.metadata))
    }
    
    func testQueryInclude_combination() {
        let include: Query.Include = [.count, .contentType]
        XCTAssertTrue(include.contains(.count))
        XCTAssertTrue(include.contains(.contentType))
        XCTAssertFalse(include.contains(.unpublished))
    }
    
    func testQueryInclude_multipleOptions() {
        let include: Query.Include = [.count, .unpublished, .fallback]
        XCTAssertTrue(include.contains(.count))
        XCTAssertTrue(include.contains(.unpublished))
        XCTAssertTrue(include.contains(.fallback))
        XCTAssertFalse(include.contains(.contentType))
    }
    
    // MARK: - ContentTypeQuery.Include Tests
    
    func testContentTypeQueryInclude_count() {
        let include = ContentTypeQuery.Include.count
        XCTAssertEqual(include.rawValue, 1)
    }
    
    func testContentTypeQueryInclude_globalFields() {
        let include = ContentTypeQuery.Include.globalFields
        XCTAssertEqual(include.rawValue, 2)
    }
    
    func testContentTypeQueryInclude_all() {
        let all = ContentTypeQuery.Include.all
        XCTAssertTrue(all.contains(.count))
        XCTAssertTrue(all.contains(.globalFields))
    }
    
    func testContentTypeQueryInclude_combination() {
        let include: ContentTypeQuery.Include = [.count, .globalFields]
        XCTAssertTrue(include.contains(.count))
        XCTAssertTrue(include.contains(.globalFields))
    }
    
    // MARK: - AssetQuery.Include Tests
    
    func testAssetQueryInclude_count() {
        let include = AssetQuery.Include.count
        XCTAssertEqual(include.rawValue, 1)
    }
    
    func testAssetQueryInclude_relativeURL() {
        let include = AssetQuery.Include.relativeURL
        XCTAssertEqual(include.rawValue, 2)
    }
    
    func testAssetQueryInclude_dimension() {
        let include = AssetQuery.Include.dimension
        XCTAssertEqual(include.rawValue, 4)
    }
    
    func testAssetQueryInclude_fallback() {
        let include = AssetQuery.Include.fallback
        XCTAssertEqual(include.rawValue, 8)
    }
    
    func testAssetQueryInclude_metadata() {
        let include = AssetQuery.Include.metadata
        XCTAssertEqual(include.rawValue, 16)
    }
    
    func testAssetQueryInclude_all() {
        let all = AssetQuery.Include.all
        XCTAssertTrue(all.contains(.count))
        XCTAssertTrue(all.contains(.relativeURL))
        XCTAssertTrue(all.contains(.dimension))
        XCTAssertTrue(all.contains(.fallback))
        XCTAssertTrue(all.contains(.metadata))
    }
    
    func testAssetQueryInclude_combination() {
        let include: AssetQuery.Include = [.count, .dimension]
        XCTAssertTrue(include.contains(.count))
        XCTAssertTrue(include.contains(.dimension))
        XCTAssertFalse(include.contains(.relativeURL))
    }
    
    func testAssetQueryInclude_multipleOptions() {
        let include: AssetQuery.Include = [.relativeURL, .dimension, .metadata]
        XCTAssertTrue(include.contains(.relativeURL))
        XCTAssertTrue(include.contains(.dimension))
        XCTAssertTrue(include.contains(.metadata))
        XCTAssertFalse(include.contains(.count))
    }
    
    // MARK: - QueryConstants Tests
    
    func testQueryConstants_maxLimit() {
        XCTAssertEqual(QueryConstants.maxLimit, 1000)
    }
    
    // MARK: - Query.Include Edge Cases
    
    func testQueryInclude_emptySet() {
        let include = Query.Include()
        XCTAssertFalse(include.contains(.count))
        XCTAssertFalse(include.contains(.unpublished))
    }
    
    func testQueryInclude_rawValueInit() {
        let include = Query.Include(rawValue: 5) // count + contentType
        XCTAssertTrue(include.contains(.count))
        XCTAssertTrue(include.contains(.contentType))
        XCTAssertFalse(include.contains(.unpublished))
    }
    
    func testContentTypeQueryInclude_emptySet() {
        let include = ContentTypeQuery.Include()
        XCTAssertFalse(include.contains(.count))
        XCTAssertFalse(include.contains(.globalFields))
    }
    
    func testAssetQueryInclude_emptySet() {
        let include = AssetQuery.Include()
        XCTAssertFalse(include.contains(.count))
        XCTAssertFalse(include.contains(.dimension))
    }
    
    static var allTests = [
        ("testQueryInclude_count", testQueryInclude_count),
        ("testQueryInclude_unpublished", testQueryInclude_unpublished),
        ("testQueryInclude_contentType", testQueryInclude_contentType),
        ("testQueryInclude_globalField", testQueryInclude_globalField),
        ("testQueryInclude_refContentTypeUID", testQueryInclude_refContentTypeUID),
        ("testQueryInclude_fallback", testQueryInclude_fallback),
        ("testQueryInclude_embeddedItems", testQueryInclude_embeddedItems),
        ("testQueryInclude_metadata", testQueryInclude_metadata),
        ("testQueryInclude_all", testQueryInclude_all),
        ("testQueryInclude_combination", testQueryInclude_combination),
        ("testQueryInclude_multipleOptions", testQueryInclude_multipleOptions),
        ("testContentTypeQueryInclude_count", testContentTypeQueryInclude_count),
        ("testContentTypeQueryInclude_globalFields", testContentTypeQueryInclude_globalFields),
        ("testContentTypeQueryInclude_all", testContentTypeQueryInclude_all),
        ("testContentTypeQueryInclude_combination", testContentTypeQueryInclude_combination),
        ("testAssetQueryInclude_count", testAssetQueryInclude_count),
        ("testAssetQueryInclude_relativeURL", testAssetQueryInclude_relativeURL),
        ("testAssetQueryInclude_dimension", testAssetQueryInclude_dimension),
        ("testAssetQueryInclude_fallback", testAssetQueryInclude_fallback),
        ("testAssetQueryInclude_metadata", testAssetQueryInclude_metadata),
        ("testAssetQueryInclude_all", testAssetQueryInclude_all),
        ("testAssetQueryInclude_combination", testAssetQueryInclude_combination),
        ("testAssetQueryInclude_multipleOptions", testAssetQueryInclude_multipleOptions),
        ("testQueryConstants_maxLimit", testQueryConstants_maxLimit),
        ("testQueryInclude_emptySet", testQueryInclude_emptySet),
        ("testQueryInclude_rawValueInit", testQueryInclude_rawValueInit),
        ("testContentTypeQueryInclude_emptySet", testContentTypeQueryInclude_emptySet),
        ("testAssetQueryInclude_emptySet", testAssetQueryInclude_emptySet)
    ]
}

