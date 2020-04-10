//
//  SyncAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 07/04/20.
//

import XCTest
@testable import Contentstack
import DVR

var paginationToken = ""
var syncToken = ""

class SyncAPITest: XCTestCase {

    static let stack = TestContentstackClient.testStack(cassetteName: "SyncTest")
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
        SyncAPITest.stack.sync(syncStack, syncTypes: syncTypes, then: { (result: Result<SyncStack, Error>) in
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

    func testSyncInit() {
        let networkExpectation = expectation(description: "Sync test exception")
        sync(networkExpectation: networkExpectation) { (syncStack) in
            if !syncStack.hasMorePages {
                XCTAssertEqual(syncStack.items.count, 23)
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

    func testSyncToken() {
        let syncStack = SyncStack(syncToken: syncToken)
        let networkExpectation = expectation(description: "Sync Token test exception")
        sync(syncStack, networkExpectation: networkExpectation) { (syncStack: SyncStack) in
            if !syncStack.hasMorePages {
                XCTAssertEqual(syncStack.items.count, 0)
                XCTAssertFalse(syncStack.syncToken.isEmpty)
                XCTAssertTrue(syncStack.paginationToken.isEmpty)
                networkExpectation.fulfill()
            }
        }
    }

    func testSyncPagination() {
        let syncStack = SyncStack(paginationToken: paginationToken)
        let networkExpectation = expectation(description: "Sync Pagination test exception")
        sync(syncStack, networkExpectation: networkExpectation) { (syncStack: SyncStack) in
            if !syncStack.hasMorePages {
                XCTAssertEqual(syncStack.items.count, 23)
                XCTAssertFalse(syncStack.syncToken.isEmpty)
                XCTAssertTrue(syncStack.paginationToken.isEmpty)
                networkExpectation.fulfill()
            }
        }
    }

    func testSyncAssetPublished() {
        let networkExpectation = expectation(description: "Sync Asset Publish test exception")
        sync(syncTypes: [.publishType(.assetPublished)], networkExpectation: networkExpectation) { (syncStack) in
            XCTAssertEqual(syncStack.items.count, 8)
            XCTAssertFalse(syncStack.syncToken.isEmpty)
            XCTAssertTrue(syncStack.paginationToken.isEmpty)
            networkExpectation.fulfill()
        }
    }

    func testSyncForContentType() {
        let networkExpectation = expectation(description: "Sync ContentType test exception")
        sync(syncTypes: [.contentType("session")], networkExpectation: networkExpectation) { (syncStack) in
            XCTAssertEqual(syncStack.items.count, 31)
            XCTAssertFalse(syncStack.syncToken.isEmpty)
            XCTAssertTrue(syncStack.paginationToken.isEmpty)
            networkExpectation.fulfill()
        }
    }

    func testSyncLocale() {
        let networkExpectation = expectation(description: "Sync Locale test exception")
        sync(syncTypes: [.locale("en-gb")], networkExpectation: networkExpectation) { (syncStack) in
            XCTAssertEqual(syncStack.items.count, 0)
            XCTAssertFalse(syncStack.syncToken.isEmpty)
            XCTAssertTrue(syncStack.paginationToken.isEmpty)
            networkExpectation.fulfill()
        }
    }

    func testSyncFromStartDate() {
        let networkExpectation = expectation(description: "Sync Start From Date test exception")
        #if API_TEST
        let date = Date()
        #else
        let date = "2020-04-10T07:28:22Z".iso8601StringDate!
        #endif
        sync(syncTypes: [.startFrom(date)], networkExpectation: networkExpectation) { (syncStack) in
            XCTAssertEqual(syncStack.items.count, 0)
            XCTAssertFalse(syncStack.syncToken.isEmpty)
            XCTAssertTrue(syncStack.paginationToken.isEmpty)
            networkExpectation.fulfill()
        }
    }

    func testSyncContentTypeAndLocale() {
        let networkExpectation = expectation(description: "Sync ContentType and Locale test exception")
        sync(syncTypes: [.contentType("session"), .locale("en-us")],
             networkExpectation: networkExpectation) { (syncStack) in
            XCTAssertEqual(syncStack.items.count, 31)
            XCTAssertFalse(syncStack.syncToken.isEmpty)
            XCTAssertTrue(syncStack.paginationToken.isEmpty)
            networkExpectation.fulfill()
        }
    }
}
