//
//  ContentTypeTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import XCTest
@testable import Contentstack

final class ContentTypeTests: XCTestCase {
    let uid = "testUID"

    func testEndPoint() {
        let endPoint = ContentTypeModel.endpoint
        XCTAssertEqual(endPoint.pathComponent, "content_types")
    }

    func testFetch_withoutUID() {
        expectFatalError(expectedMessage: "Please provide ContentType uid") {
            makeContentTypeSut().fetch { (result: Result<AssetModel, Error>, response) in
                
            }
        }
    }

    func testEntry_ContentTypeUidNotProvided_FatalError() {
        expectFatalError(expectedMessage: "Please provide ContentType uid") {
            _ = makeEntrySut()
        }
    }

    func testEntry_UidNotProvided_ShouldReturnEntry() {
        let entry = makeEntrySut(contentTypeuid: "ContentType")
        XCTAssertNotNil(entry)
        XCTAssertNil(entry.uid)
    }

    func testEntry_UidProvided_ShouldReturnEntryWithUID() {
        let entry = makeEntrySut(contentTypeuid: "ContentType", entryUid: uid)
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry.uid, uid)
    }

    func testContentTypeQuery() {
        let contentTypeQuery = makeContentTypeSut().query()
        XCTAssertNotNil(contentTypeQuery)
    }

    func testContentTypeQuery_withContentTypeUID() {
        let uid = "contentTypeUID"
        let contentTypeQuery = makeContentTypeSut(uid: uid).query()
        XCTAssertEqual(contentTypeQuery.queryParameter[ContentTypeModel.QueryableCodingKey.uid.rawValue] as? String, uid)
    }

    static var allTests = [
        ("testEntry_ContentTypeUidNotProvided_FatalError",
         testEntry_ContentTypeUidNotProvided_FatalError),
        ("testEntry_UidNotProvided_ShouldReturnEntry",
         testEntry_UidNotProvided_ShouldReturnEntry),
        ("testEntry_UidProvided_ShouldReturnEntryWithUID",
         testEntry_UidProvided_ShouldReturnEntryWithUID),
        ("testContentTypeQuery_withContentTypeUID",
         testContentTypeQuery_withContentTypeUID)
    ]
}
