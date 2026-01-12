//
//  CSDefinitionsTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class CSDefinitionsTest: XCTestCase {
    
    // MARK: - HTTPMethod Tests
    
    func testHTTPMethod_get() {
        let method = HTTPMethod.get
        XCTAssertEqual(method.rawValue, "GET")
        XCTAssertEqual(method.httpMethod, "GET")
    }
    
    func testHTTPMethod_post() {
        let method = HTTPMethod.post
        XCTAssertEqual(method.rawValue, "POST")
        XCTAssertEqual(method.httpMethod, "POST")
    }
    
    func testHTTPMethod_put() {
        let method = HTTPMethod.put
        XCTAssertEqual(method.rawValue, "PUT")
        XCTAssertEqual(method.httpMethod, "PUT")
    }
    
    func testHTTPMethod_delete() {
        let method = HTTPMethod.delete
        XCTAssertEqual(method.rawValue, "DELETE")
        XCTAssertEqual(method.httpMethod, "DELETE")
    }
    
    // MARK: - ContentstackRegion Tests
    
    func testContentstackRegion_us() {
        let region = ContentstackRegion.us
        XCTAssertEqual(region.rawValue, "us")
    }
    
    func testContentstackRegion_eu() {
        let region = ContentstackRegion.eu
        XCTAssertEqual(region.rawValue, "eu")
    }
    
    func testContentstackRegion_azureNA() {
        let region = ContentstackRegion.azure_na
        XCTAssertEqual(region.rawValue, "azure-na")
    }
    
    func testContentstackRegion_azureEU() {
        let region = ContentstackRegion.azure_eu
        XCTAssertEqual(region.rawValue, "azure-eu")
    }
    
    func testContentstackRegion_gcpNA() {
        let region = ContentstackRegion.gcp_na
        XCTAssertEqual(region.rawValue, "gcp-na")
    }
    
    func testContentstackRegion_gcpEU() {
        let region = ContentstackRegion.gcp_eu
        XCTAssertEqual(region.rawValue, "gcp-eu")
    }
    
    func testContentstackRegion_au() {
        let region = ContentstackRegion.au
        XCTAssertEqual(region.rawValue, "au")
    }
    
    func testContentstackRegion_equality() {
        let region1 = ContentstackRegion.us
        let region2 = ContentstackRegion.us
        
        XCTAssertEqual(region1, region2)
    }
    
    func testContentstackRegion_inequality() {
        let region1 = ContentstackRegion.us
        let region2 = ContentstackRegion.eu
        
        XCTAssertNotEqual(region1, region2)
    }
    
    // MARK: - CachePolicy Tests
    
    func testCachePolicy_networkOnly() {
        let policy = CachePolicy.networkOnly
        
        switch policy {
        case .networkOnly:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected networkOnly policy")
        }
    }
    
    func testCachePolicy_cacheOnly() {
        let policy = CachePolicy.cacheOnly
        
        switch policy {
        case .cacheOnly:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected cacheOnly policy")
        }
    }
    
    func testCachePolicy_cacheElseNetwork() {
        let policy = CachePolicy.cacheElseNetwork
        
        switch policy {
        case .cacheElseNetwork:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected cacheElseNetwork policy")
        }
    }
    
    func testCachePolicy_networkElseCache() {
        let policy = CachePolicy.networkElseCache
        
        switch policy {
        case .networkElseCache:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected networkElseCache policy")
        }
    }
    
    func testCachePolicy_cacheThenNetwork() {
        let policy = CachePolicy.cacheThenNetwork
        
        switch policy {
        case .cacheThenNetwork:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected cacheThenNetwork policy")
        }
    }
    
    // MARK: - ResponseType Tests
    
    func testResponseType_cache() {
        let responseType = ResponseType.cache
        
        switch responseType {
        case .cache:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected cache response type")
        }
    }
    
    func testResponseType_network() {
        let responseType = ResponseType.network
        
        switch responseType {
        case .network:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected network response type")
        }
    }
    
    // MARK: - All Regions Test
    
    func testAllRegions_uniqueRawValues() {
        let regions = [
            ContentstackRegion.us,
            ContentstackRegion.eu,
            ContentstackRegion.azure_na,
            ContentstackRegion.azure_eu,
            ContentstackRegion.gcp_na,
            ContentstackRegion.gcp_eu,
            ContentstackRegion.au
        ]
        
        let rawValues = regions.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        
        XCTAssertEqual(rawValues.count, uniqueRawValues.count, "All regions should have unique raw values")
    }
    
    static var allTests = [
        ("testHTTPMethod_get", testHTTPMethod_get),
        ("testHTTPMethod_post", testHTTPMethod_post),
        ("testHTTPMethod_put", testHTTPMethod_put),
        ("testHTTPMethod_delete", testHTTPMethod_delete),
        ("testContentstackRegion_us", testContentstackRegion_us),
        ("testContentstackRegion_eu", testContentstackRegion_eu),
        ("testContentstackRegion_azureNA", testContentstackRegion_azureNA),
        ("testContentstackRegion_azureEU", testContentstackRegion_azureEU),
        ("testContentstackRegion_gcpNA", testContentstackRegion_gcpNA),
        ("testContentstackRegion_gcpEU", testContentstackRegion_gcpEU),
        ("testContentstackRegion_au", testContentstackRegion_au),
        ("testContentstackRegion_equality", testContentstackRegion_equality),
        ("testContentstackRegion_inequality", testContentstackRegion_inequality),
        ("testCachePolicy_networkOnly", testCachePolicy_networkOnly),
        ("testCachePolicy_cacheOnly", testCachePolicy_cacheOnly),
        ("testCachePolicy_cacheElseNetwork", testCachePolicy_cacheElseNetwork),
        ("testCachePolicy_networkElseCache", testCachePolicy_networkElseCache),
        ("testCachePolicy_cacheThenNetwork", testCachePolicy_cacheThenNetwork),
        ("testResponseType_cache", testResponseType_cache),
        ("testResponseType_network", testResponseType_network),
        ("testAllRegions_uniqueRawValues", testAllRegions_uniqueRawValues)
    ]
}

