//
//  StackTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import XCTest
@testable import ContentstackSwift

final class StackTests: XCTestCase {
    let uid = "testUID"
    func testContentType_UIDNotProvided_UIDShouldbeNil() {
        let contentType = makeContentTypeSut()
        XCTAssertNotNil(contentType)
        XCTAssertNil(contentType.uid)
    }

    func testContentType_UIDProvided_UIDShouldPresent() {
        let contentType = makeContentTypeSut(uid: uid)
        XCTAssertEqual(contentType.uid, uid)
    }

    func testAsset_UIDNotProvided_UIDShouldbeNil() {
        let asset = makeAssetSut()
        XCTAssertNotNil(asset)
    }

    func testAsset_UIDProvided_UIDShouldPresent() {
        let asset = makeAssetSut(uid: uid)
        XCTAssertEqual(asset.uid, uid)
    }

    static var allTests = [
           ("testContentType_UIDNotProvided_UIDShouldbeNil", testContentType_UIDNotProvided_UIDShouldbeNil),
           ("testContentType_UIDProvided_UIDShouldPresent", testContentType_UIDProvided_UIDShouldPresent),
           ("testAsset_UIDNotProvided_UIDShouldbeNil", testAsset_UIDNotProvided_UIDShouldbeNil),
           ("testAsset_UIDProvided_UIDShouldPresent", testAsset_UIDProvided_UIDShouldPresent)
       ]
}
