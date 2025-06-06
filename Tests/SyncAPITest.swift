//
//  SyncAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 07/04/20.
//

import XCTest
@testable import ContentstackSwift
import DVR

class SyncAPITest: XCTestCase {

    static let stack = TestContentstackClient.testStack(cassetteName: "SyncTest")
    static var paginationToken = ""
    static var syncToken = ""
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

    func test01SyncInit() {
        let networkExpectation = expectation(description: "Sync test exception")
        sync(networkExpectation: networkExpectation) { (syncStack) in
            if !syncStack.hasMorePages {
                XCTAssertEqual(syncStack.items.count, 25)
                XCTAssertFalse(syncStack.syncToken.isEmpty)
                XCTAssertTrue(syncStack.paginationToken.isEmpty)
                SyncAPITest.syncToken = syncStack.syncToken
                networkExpectation.fulfill()
            } else {
                XCTAssertEqual(syncStack.items.count, 100)
                XCTAssertFalse(syncStack.paginationToken.isEmpty)
                XCTAssertTrue(syncStack.syncToken.isEmpty)
                SyncAPITest.paginationToken = syncStack.paginationToken
            }
        }
    }

    func test02SyncToken() {
        let syncStack = SyncStack(syncToken: SyncAPITest.syncToken)
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

    func test03SyncPagination() {
        let syncStack = SyncStack(paginationToken: SyncAPITest.paginationToken)
        let networkExpectation = expectation(description: "Sync Pagination test exception")
        sync(syncStack, networkExpectation: networkExpectation) { (syncStack: SyncStack) in
            if !syncStack.hasMorePages {
                XCTAssertEqual(syncStack.items.count, 25)
                XCTAssertFalse(syncStack.syncToken.isEmpty)
                XCTAssertTrue(syncStack.paginationToken.isEmpty)
                networkExpectation.fulfill()
            }
        }
    }

    func test04SyncAssetPublished() {
        let networkExpectation = expectation(description: "Sync Asset Publish test exception")
        sync(syncTypes: [.publishType(.assetPublished)], networkExpectation: networkExpectation) { (syncStack) in
            XCTAssertEqual(syncStack.items.count, 8)
            XCTAssertFalse(syncStack.syncToken.isEmpty)
            XCTAssertTrue(syncStack.paginationToken.isEmpty)
            networkExpectation.fulfill()
        }
    }

    func test05SyncForContentType() {
        let networkExpectation = expectation(description: "Sync ContentType test exception")
        sync(syncTypes: [.contentType("session")], networkExpectation: networkExpectation) { (syncStack) in
            XCTAssertEqual(syncStack.items.count, 31)
            XCTAssertFalse(syncStack.syncToken.isEmpty)
            XCTAssertTrue(syncStack.paginationToken.isEmpty)
            networkExpectation.fulfill()
        }
    }

    func test06SyncLocale() {
        let networkExpectation = expectation(description: "Sync Locale test exception")
        sync(syncTypes: [.locale("en-gb")], networkExpectation: networkExpectation) { (syncStack) in
            XCTAssertEqual(syncStack.items.count, 0)
            XCTAssertFalse(syncStack.syncToken.isEmpty)
            XCTAssertTrue(syncStack.paginationToken.isEmpty)
            networkExpectation.fulfill()
        }
    }
    
//Skipping this test! Works fine. Manual date change is required for different stacks.
//    func test07SyncFromStartDate() {
//        let networkExpectation = expectation(description: "Sync Start From Date test exception")
//        #if API_TEST
//        let date = Date()
//        #else
//        let date = "2020-04-29T08:05:56Z".iso8601StringDate!
//        #endif
//        sync(syncTypes: [.startFrom(date)], networkExpectation: networkExpectation) { (syncStack) in
//            XCTAssertEqual(syncStack.items.count, 100)
//            XCTAssertFalse(syncStack.syncToken.isEmpty)
//            XCTAssertTrue(syncStack.paginationToken.isEmpty)
//            networkExpectation.fulfill()
//        }
//    }

    func test08SyncContentTypeAndLocale() {
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
