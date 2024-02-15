//
//  AsyncQueryOnAPITest2.swift
//  Contentstack iOS Tests
//
//  Created by Vikram Kalta on 04/01/2024.
//

import XCTest
@testable import Contentstack
import DVR

var kEntryUID = ""
var kEntryTitle = ""

class AsyncQueryOnAPITest2: XCTestCase {
    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "QueryOn")
    
    func getEntry(uid: String? = nil) -> Entry {
        return AsyncQueryOnAPITest2.stack.contentType(uid: "session").entry(uid: uid)
    }
    
    func getEntryQuery<EntryType>(_ entry: EntryType.Type) -> QueryOn<EntryType> {
        return self.getEntry().query(entry)
    }

    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func test01FindAll_Session() async {
        let networkExpectation = expectation(description: "Fetch All Entry Test")
        let data: ContentstackResponse<Session> = try! await self.getEntryQuery(Session.self).locale("en-us").find()
        XCTAssertEqual(data.items.count, 31)
        if let entry = data.items.first {
            kEntryUID = entry.uid
            kEntryTitle = entry.title
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }

    func test02FindAll_SessionReference() async {
        let networkExpectation = expectation(description: "Fetch All Entry Test")
        let data: ContentstackResponse<SessionWithTrackReference> = try! await self.getEntryQuery(SessionWithTrackReference.self).locale("en-us").where(queryableCodingKey: SessionWithTrackReference.FieldKeys.sessionId, .equals(2695)).includeReference(with: ["track"]).find()
        XCTAssertEqual(data.items.count, 1)
        if let session = data.items.first {
            XCTAssertEqual(session.sessionId, 2695)
            XCTAssertEqual(session.track.count, 0)
            if let track = session.track.first {
                XCTAssertEqual(track.title, "Virtualizing Applications")
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
}
