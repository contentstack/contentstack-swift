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
    #if os(iOS) || os(tvOS) || os(watchOS)
    func testFetch_withoutUID() {
        expectFatalError(expectedMessage: "Please provide Asset uid") {
            makeAssetSut().fetch { (result: Result<AssetModel, Error>, response) in
                
            }
        }
    }
    #endif
    func testAssetInclude() {
        let assetDimension = makeAssetSut().includeDimension()
        XCTAssertEqual(assetDimension.parameters.query(), "include_dimension=true")
        let assetRelativeURL = makeAssetSut().includeRelativeURL()
        XCTAssertEqual(assetRelativeURL.parameters.query(), "relative_urls=true")
        let asset = makeAssetSut().includeRelativeURL().includeDimension()
        XCTAssertEqual(asset.parameters.query(), "include_dimension=true&relative_urls=true")
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
