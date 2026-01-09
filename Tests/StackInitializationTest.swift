//
//  StackInitializationTest.swift
//  Contentstack
//
//  Created for improved test coverage
//

import XCTest
@testable import ContentstackSwift

class StackInitializationTest: XCTestCase {
    
    // MARK: - Stack Properties Tests
    
    func testStack_initialization() {
        let stack = makeStackSut(
            // file deepcode ignore NoHardcodedCredentials/test: <please specify a reason of ignoring this>
            apiKey: "test_key",
            deliveryToken: "test_token",
            environment: "test_env"
        )
        
        XCTAssertEqual(stack.apiKey, "test_key")
        XCTAssertEqual(stack.deliveryToken, "test_token")
        XCTAssertEqual(stack.environment, "test_env")
        XCTAssertNotNil(stack.jsonDecoder)
    }
    
    func testStack_cachePolicy_default() {
        let stack = makeStackSut()
        
        XCTAssertEqual(stack.cachePolicy, .networkOnly)
    }
    
    func testStack_cachePolicy_modification() {
        let stack = makeStackSut()
        stack.cachePolicy = .cacheOnly
        
        XCTAssertEqual(stack.cachePolicy, .cacheOnly)
    }
    
    func testStack_contentType_withoutUID() {
        let stack = makeStackSut()
        let contentType = stack.contentType(uid: nil)
        
        XCTAssertNil(contentType.uid)
        XCTAssertNotNil(contentType)
    }
    
    func testStack_contentType_withUID() {
        let stack = makeStackSut()
        let uid = "test_content_type_uid"
        let contentType = stack.contentType(uid: uid)
        
        XCTAssertEqual(contentType.uid, uid)
    }
    
    func testStack_asset_withoutUID() {
        let stack = makeStackSut()
        let asset = stack.asset(uid: nil)
        
        XCTAssertNil(asset.uid)
        XCTAssertNotNil(asset)
    }
    
    func testStack_asset_withUID() {
        let stack = makeStackSut()
        let uid = "test_asset_uid"
        let asset = stack.asset(uid: uid)
        
        XCTAssertEqual(asset.uid, uid)
    }
    
    func testStack_taxonomy() {
        let stack = makeStackSut()
        let taxonomy = stack.taxonomy()
        
        XCTAssertNotNil(taxonomy)
        XCTAssertEqual(taxonomy.cachePolicy, .networkOnly)
    }
    
    func testStack_hasURLSession() {
        let stack = makeStackSut()
        
        XCTAssertNotNil(stack.urlSession)
    }
    
    func testStack_hasJSONDecoder() {
        let stack = makeStackSut()
        
        XCTAssertNotNil(stack.jsonDecoder)
    }
    
    func testStack_regionProperty() {
        let stack = makeStackSut(region: .eu)
        
        XCTAssertEqual(stack.region, .eu)
    }
    
    func testStack_apiVersionProperty() {
        let stack = makeStackSut(apiVersion: "v4")
        
        XCTAssertEqual(stack.apiVersion, "v4")
    }
    
    func testStack_hostProperty() {
        let customHost = "custom.host.com"
        let stack = makeStackSut(host: customHost)
        
        XCTAssertEqual(stack.host, customHost)
    }
    
    func testStack_environmentProperty() {
        let environment = "production"
        let stack = makeStackSut(environment: environment)
        
        XCTAssertEqual(stack.environment, environment)
    }
    
    func testStack_deliveryTokenProperty() {
        let token = "test_delivery_token"
        let stack = makeStackSut(deliveryToken: token)
        
        XCTAssertEqual(stack.deliveryToken, token)
    }
    
    func testStack_globalField() {
        let stack = makeStackSut()
        let uid = "test_global_field_uid"
        let globalField = stack.globalField(uid: uid)
        
        XCTAssertNotNil(globalField)
        XCTAssertEqual(globalField.uid, uid)
    }
    
    func testStack_allRegions() {
        let regions: [ContentstackRegion] = [.us, .eu, .azure_na, .azure_eu, .gcp_na, .gcp_eu, .au]
        
        for region in regions {
            let stack = makeStackSut(region: region)
            XCTAssertEqual(stack.region, region)
        }
    }
    
    func testStack_withBranch() {
        let branch = "feature-branch"
        let stack = makeStackSut(branch: branch)
        
        XCTAssertEqual(stack.branch, branch)
    }
    
    func testStack_withoutBranch() {
        let stack = makeStackSut(branch: nil)
        
        XCTAssertNil(stack.branch)
    }
    
    func testStack_customHost() {
        let customHost = "custom.example.com"
        let stack = makeStackSut(host: customHost)
        
        XCTAssertEqual(stack.host, customHost)
    }
    
    func testStack_customAPIVersion() {
        let apiVersion = "v4"
        let stack = makeStackSut(apiVersion: apiVersion)
        
        XCTAssertEqual(stack.apiVersion, apiVersion)
    }
    
    static var allTests = [
        ("testStack_initialization", testStack_initialization),
        ("testStack_cachePolicy_default", testStack_cachePolicy_default),
        ("testStack_cachePolicy_modification", testStack_cachePolicy_modification),
        ("testStack_contentType_withoutUID", testStack_contentType_withoutUID),
        ("testStack_contentType_withUID", testStack_contentType_withUID),
        ("testStack_asset_withoutUID", testStack_asset_withoutUID),
        ("testStack_asset_withUID", testStack_asset_withUID),
        ("testStack_taxonomy", testStack_taxonomy),
        ("testStack_hasURLSession", testStack_hasURLSession),
        ("testStack_hasJSONDecoder", testStack_hasJSONDecoder),
        ("testStack_regionProperty", testStack_regionProperty),
        ("testStack_apiVersionProperty", testStack_apiVersionProperty),
        ("testStack_hostProperty", testStack_hostProperty),
        ("testStack_environmentProperty", testStack_environmentProperty),
        ("testStack_deliveryTokenProperty", testStack_deliveryTokenProperty),
        ("testStack_globalField", testStack_globalField),
        ("testStack_allRegions", testStack_allRegions),
        ("testStack_withBranch", testStack_withBranch),
        ("testStack_withoutBranch", testStack_withoutBranch),
        ("testStack_customHost", testStack_customHost),
        ("testStack_customAPIVersion", testStack_customAPIVersion)
    ]
}

