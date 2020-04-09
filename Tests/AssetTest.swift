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

//    func testEndPointComponent_withoutUID() {
//        var components: URLComponents = URLComponents(string: "https://localhost.com/api")!
//        let entry = makeAssetSut()
//        entry.endPoint(components: &components)
//        XCTAssertEqual(components.path, "/api/assets")
//    }
//
//    func testEntryEndPointComponent_withUID() {
//        var components: URLComponents = URLComponents(string: "https://localhost.com/api")!
//        let entry = makeAssetSut(uid: "asset_uid")
//        entry.endPoint(components: &components)
//        XCTAssertEqual(components.path, "/api/assets/asset_uid")
//    }

    func testEntryQuery_withoutUID() {
        let query = makeAssetSut().query()
        XCTAssertNotNil(query)
        XCTAssertEqual(query.parameters.query(), "")
        XCTAssertEqual(query.queryParameter.jsonString, "{\n\n}")
    }

    func testEntryQuery_withUID() {
        let query = makeAssetSut(uid: "asset_uid").query()
        XCTAssertNotNil(query)
        XCTAssertEqual(query.parameters.query(), "")
        XCTAssertEqual(query.queryParameter.jsonString, "{\n  \"uid\" : \"asset_uid\"\n}")
    }

}
