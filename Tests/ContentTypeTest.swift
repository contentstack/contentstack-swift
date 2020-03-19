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

    static var allTests = [
        ("testEntry_ContentTypeUidNotProvided_FatalError",
         testEntry_ContentTypeUidNotProvided_FatalError),
        ("testEntry_UidNotProvided_ShouldReturnEntry",
         testEntry_UidNotProvided_ShouldReturnEntry),
        ("testEntry_UidProvided_ShouldReturnEntryWithUID",
         testEntry_UidProvided_ShouldReturnEntryWithUID)
    ]
}
