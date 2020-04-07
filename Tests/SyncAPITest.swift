//
//  SyncAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 07/04/20.
//

import XCTest
@testable import Contentstack
class SyncAPITest: XCTestCase {

    func testSyncInit() {
        let networkExpectation = expectation(description: "Sync test exception")

        TestContentstackClient.stack.sync { (result: Result<SyncStack, Error>) in
            switch result {
            case .success(let syncStack):
                if !syncStack.hasMorePages {
                    XCTAssertFalse(syncStack.syncToken.isEmpty)
                    XCTAssertTrue(syncStack.paginationToken.isEmpty)
                    networkExpectation.fulfill()
                } else {
                    XCTAssertEqual(syncStack.items.count, 100)
                    XCTAssertFalse(syncStack.paginationToken.isEmpty)
                    XCTAssertTrue(syncStack.syncToken.isEmpty)
                }
            case .failure(let error):
                XCTFail("\(error)")
                networkExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 20, handler: nil)
    }
}
