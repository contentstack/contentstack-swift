//
//  AsyncSyncAPITest.swift
//  Contentstack
//
//  Created by Jigar Kanani on 10/10/23.
//

import XCTest
@testable import Contentstack
import DVR

//var paginationToken = ""
//var syncToken = ""

class AsyncSyncAPITest: XCTestCase {

    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "SyncTest")
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func sync(_ syncStack: SyncStack = SyncStack(),
              syncTypes: [SyncStack.SyncableTypes] = [.all],
              networkExpectation: XCTestExpectation,
              then completion:@escaping (_ space: SyncStack) -> Void) {
        AsyncSyncAPITest.stack.sync(syncStack, syncTypes: syncTypes, then: { (result: Result<SyncStack, Error>) in
            switch result {
            case .success(let syncStack):
                completion(syncStack)
            case .failure(let error):
                XCTFail("\(error)")
                networkExpectation.fulfill()
            }
        })
        waitForExpectations(timeout: 20, handler: nil)
    }

    func AsyncTest01SyncInit() {
        let networkExpectation = expectation(description: "Sync test exception")
        sync(networkExpectation: networkExpectation) { (syncStack) in
            if !syncStack.hasMorePages {
                XCTAssertEqual(syncStack.items.count, 29)
                XCTAssertFalse(syncStack.syncToken.isEmpty)
                XCTAssertTrue(syncStack.paginationToken.isEmpty)
                syncToken = syncStack.syncToken
                networkExpectation.fulfill()
            } else {
                XCTAssertEqual(syncStack.items.count, 100)
                XCTAssertFalse(syncStack.paginationToken.isEmpty)
                XCTAssertTrue(syncStack.syncToken.isEmpty)
                paginationToken = syncStack.paginationToken
            }
        }
    }
}
