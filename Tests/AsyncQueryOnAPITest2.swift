//
//  AsyncQueryOnAPITest2.swift
//  Contentstack iOS Tests
//
//  Created by Vikram Kalta on 04/01/2024.
//

import XCTest
@testable import Contentstack
import DVR

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
        let (data, _): (Result<ContentstackResponse<Session>, Error>, ResponseType) = try! await self.getEntryQuery(Session.self).locale("en-us").find()
        switch data {
        case .success(let contentstackResponse):
            XCTAssertEqual(contentstackResponse.items.count, 31)
            if let entry = contentstackResponse.items.first {
                kEntryUID = entry.uid
                kEntryTitle = entry.title
            }
        case .failure(let error):
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }

    func test02FindAll_SessionReference() async {
        let networkExpectation = expectation(description: "Fetch All Entry Test")
        let (data, _): (Result<ContentstackResponse<SessionWithTrackReference>, Error>, ResponseType) = try! await self.getEntryQuery(SessionWithTrackReference.self).locale("en-us").where(queryableCodingKey: SessionWithTrackReference.FieldKeys.sessionId, .equals(2695)).includeReference(with: ["track"]).find()
        switch data {
        case .success(let contentstackResponse):
            XCTAssertEqual(contentstackResponse.items.count, 1)
            if let session = contentstackResponse.items.first {
                XCTAssertEqual(session.sessionId, 2695)
                XCTAssertEqual(session.track.count, 1)
                if let track = session.track.first {
                    XCTAssertEqual(track.title, "Virtualizing Applications")
                }
            }
        case .failure(let error):
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
}
