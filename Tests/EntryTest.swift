//
//  EntryTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 23/03/20.
//

import XCTest
@testable import Contentstack
class EntryTest: XCTestCase {

    func testEntry_EndPoint() {
        let endPoint = EntryModel.endpoint
        XCTAssertEqual(endPoint.pathComponent, "entries")
    }

    func testFetch_withoutUID() {
        expectFatalError(expectedMessage: "Please provide Entry uid") {
            makeEntrySut(contentTypeuid: "content").fetch { (result: Result<AssetModel, Error>, response) in
                
            }
        }
    }

    func testEntryQuery_ContentTypeUidNotProvided_FatalError() {
        expectFatalError(expectedMessage: "Please provide ContentType uid") {
            let query = Entry(nil, contentType: makeContentTypeSut()).query()
            XCTAssertNil(query)
        }
    }

    func testEntryQueryTyped_ContentTypeUidNotProvided_FatalError() {
        expectFatalError(expectedMessage: "Please provide ContentType uid") {
            let query = Entry(nil, contentType: makeContentTypeSut()).query(Product.self)
            XCTAssertNil(query)
        }
    }

    func testEntryQuery_withoutUID() {
        let query = makeEntrySut(contentTypeuid: "Content_type").query()
        XCTAssertNotNil(query)
        XCTAssertEqual(query.parameters.query(), "")
        XCTAssertEqual(query.queryParameter.jsonString, "{\n\n}")
    }

    func testEntryQuery_withUID() {
        let query = makeEntrySut(contentTypeuid: "Content_type", entryUid: "entry_uid").query()
        XCTAssertNotNil(query)
        XCTAssertEqual(query.parameters.query(), "")
        XCTAssertEqual(query.queryParameter.jsonString, "{\n  \"uid\" : \"entry_uid\"\n}")
    }

    func testEntryQueryType_withoutUID() {
        let query = makeEntrySut(contentTypeuid: "Content_type").query(Product.self)
        XCTAssertNotNil(query)
        XCTAssertEqual(query.parameters.query(), "")
        XCTAssertEqual(query.queryParameter.jsonString, "{\n\n}")
    }

    func testEntryQueryType_withUID() {
        let query = makeEntrySut(contentTypeuid: "Content_type", entryUid: "entry_uid").query(Product.self)
        XCTAssertNotNil(query)
        XCTAssertEqual(query.parameters.query(), "")
        XCTAssertEqual(query.queryParameter.jsonString, "{\n  \"uid\" : \"entry_uid\"\n}")
    }

    func testEntryLocale() {
        let entry = makeEntrySut(contentTypeuid: "Content_type").locale("en-gb")
        XCTAssertEqual(entry.parameters.query(), "locale=en-gb")
    }
}
