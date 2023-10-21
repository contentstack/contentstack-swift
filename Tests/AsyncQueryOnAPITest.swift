//
//  AsyncQueryOnAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 21/04/20.
//

import XCTest
@testable import Contentstack
import DVR

class AsyncQueryOnAPITest: XCTestCase {
    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "QueryOn")

    func getEntry(uid: String? = nil) -> Entry {
        return AsyncQueryOnAPITest.stack.contentType(uid: "session").entry(uid: uid)
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
        await self.getEntryQuery(Session.self)
            .locale("en-us")
            .asyncFind { (result: Result<ContentstackResponse<Session>, Error>, response: ResponseType) in
                switch result {
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
            }
        wait(for: [networkExpectation], timeout: 5)

    }
    
    func test01FindAll_SessionReference() async {
            let networkExpectation = expectation(description: "Fetch All Entry Test")
        await self.getEntryQuery(SessionWithTrackReference.self)
            .locale("en-us")
            .where(queryableCodingKey: SessionWithTrackReference.FieldKeys.sessionId, .equals(2695))
            .includeReference(with: ["track"])
            .asyncFind { (result: Result<ContentstackResponse<SessionWithTrackReference>, Error>, response: ResponseType) in
            switch result {
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
        }
        wait(for: [networkExpectation], timeout: 5)

    }

}
