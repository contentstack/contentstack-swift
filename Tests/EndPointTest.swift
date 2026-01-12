//
//  EndPointTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class EndPointTest: XCTestCase {
    
    // MARK: - Endpoint Tests
    
    func testEndpoint_stack() {
        let endpoint = Endpoint.stack
        XCTAssertEqual(endpoint.rawValue, "stack")
        XCTAssertEqual(endpoint.pathComponent, "stack")
    }
    
    func testEndpoint_contenttype() {
        let endpoint = Endpoint.contenttype
        XCTAssertEqual(endpoint.rawValue, "content_types")
        XCTAssertEqual(endpoint.pathComponent, "content_types")
    }
    
    func testEndpoint_entries() {
        let endpoint = Endpoint.entries
        XCTAssertEqual(endpoint.rawValue, "entries")
        XCTAssertEqual(endpoint.pathComponent, "entries")
    }
    
    func testEndpoint_assets() {
        let endpoint = Endpoint.assets
        XCTAssertEqual(endpoint.rawValue, "assets")
        XCTAssertEqual(endpoint.pathComponent, "assets")
    }
    
    func testEndpoint_sync() {
        let endpoint = Endpoint.sync
        XCTAssertEqual(endpoint.rawValue, "stacks/sync")
        XCTAssertEqual(endpoint.pathComponent, "stacks/sync")
    }
    
    func testEndpoint_taxonomies() {
        let endpoint = Endpoint.taxnomies
        XCTAssertEqual(endpoint.rawValue, "taxonomies")
        XCTAssertEqual(endpoint.pathComponent, "taxonomies")
    }
    
    func testEndpoint_globalfields() {
        let endpoint = Endpoint.globalfields
        XCTAssertEqual(endpoint.rawValue, "global_fields")
        XCTAssertEqual(endpoint.pathComponent, "global_fields")
    }
    
    // MARK: - Endpoint Comparison Tests
    
    func testEndpoint_equality() {
        let endpoint1 = Endpoint.entries
        let endpoint2 = Endpoint.entries
        
        XCTAssertEqual(endpoint1, endpoint2)
    }
    
    func testEndpoint_inequality() {
        let endpoint1 = Endpoint.entries
        let endpoint2 = Endpoint.assets
        
        XCTAssertNotEqual(endpoint1, endpoint2)
    }
    
    // MARK: - All Endpoints Test
    
    func testAllEndpoints_uniqueRawValues() {
        let endpoints = [
            Endpoint.stack,
            Endpoint.contenttype,
            Endpoint.entries,
            Endpoint.assets,
            Endpoint.sync,
            Endpoint.taxnomies,
            Endpoint.globalfields
        ]
        
        let rawValues = endpoints.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        
        XCTAssertEqual(rawValues.count, uniqueRawValues.count, "All endpoints should have unique raw values")
    }
    
    func testAllEndpoints_uniquePathComponents() {
        let endpoints = [
            Endpoint.stack,
            Endpoint.contenttype,
            Endpoint.entries,
            Endpoint.assets,
            Endpoint.sync,
            Endpoint.taxnomies,
            Endpoint.globalfields
        ]
        
        let pathComponents = endpoints.map { $0.pathComponent }
        let uniquePathComponents = Set(pathComponents)
        
        XCTAssertEqual(pathComponents.count, uniquePathComponents.count, "All endpoints should have unique path components")
    }
    
    static var allTests = [
        ("testEndpoint_stack", testEndpoint_stack),
        ("testEndpoint_contenttype", testEndpoint_contenttype),
        ("testEndpoint_entries", testEndpoint_entries),
        ("testEndpoint_assets", testEndpoint_assets),
        ("testEndpoint_sync", testEndpoint_sync),
        ("testEndpoint_taxonomies", testEndpoint_taxonomies),
        ("testEndpoint_globalfields", testEndpoint_globalfields),
        ("testEndpoint_equality", testEndpoint_equality),
        ("testEndpoint_inequality", testEndpoint_inequality),
        ("testAllEndpoints_uniqueRawValues", testAllEndpoints_uniqueRawValues),
        ("testAllEndpoints_uniquePathComponents", testAllEndpoints_uniquePathComponents)
    ]
}

