//
//  AssetTest.swift
//  Contentstack iOS Tests
//
//  Created by Uttam Ukkoji on 26/03/20.
//

import XCTest
@testable import Contentstack
class AssetTest: XCTestCase {

    func testEndPoint() {
        let endPoint = AssetModel.endpoint
        XCTAssertEqual(endPoint.pathComponent, "assets")
    }
    #if !NO_FATAL_TEST
    func testFetch_withoutUID() {
        expectFatalError(expectedMessage: "Please provide Asset uid") {
            makeAssetSut().fetch { (result: Result<AssetModel, Error>, response) in
                
            }
        }
    }
    #endif
    
    func testAssetQuery_Locale() {
        let locale = makeAssetSut().locale("en-us")
        XCTAssertEqual(locale.parameters.query(), "\(QueryParameter.locale)=en-us")
        for key in locale.parameters.keys {
            XCTAssertEqual(key, QueryParameter.locale)
        }
    }
    
    func testAssetInclude() {
        let assetDimension = makeAssetSut().includeDimension()
        XCTAssertEqual(assetDimension.parameters.query(), "include_dimension=true")
        let assetRelativeURL = makeAssetSut().includeRelativeURL()
        XCTAssertEqual(assetRelativeURL.parameters.query(), "relative_urls=true")
        let assetfallback = makeAssetSut().includeFallback()
        XCTAssertEqual(assetfallback.parameters.query(), "include_fallback=true")
        let asset = makeAssetSut().includeRelativeURL().includeDimension().includeFallback()
        XCTAssertEqual(asset.parameters.query(), "include_dimension=true&include_fallback=true&relative_urls=true")
    }

    func testAssetQuery_withoutUID() {
        let query = makeAssetSut().query()
        XCTAssertNotNil(query)
        XCTAssertEqual(query.parameters.query(), "")
        XCTAssertEqual(query.queryParameter.jsonString, "{\n\n}")
    }

    func testAssetQuery_withUID() {
        let query = makeAssetSut(uid: "asset_uid").query()
        XCTAssertNotNil(query)
        XCTAssertEqual(query.parameters.query(), "")
        XCTAssertEqual(query.queryParameter.jsonString, "{\n  \"uid\" : \"asset_uid\"\n}")
    }

}
