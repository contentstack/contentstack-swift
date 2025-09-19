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
              networkExpectation: XCTestExpectation) async {
        SyncAPITest.stack.sync(syncStack, syncTypes: syncTypes, then: { (result: Result<SyncStack, Error>) in
            switch result {
            case .success(let syncStack):
                if !syncStack.hasMorePages {
                    XCTAssertFalse(syncStack.syncToken.isEmpty)
                    XCTAssertTrue(syncStack.paginationToken.isEmpty)
                    networkExpectation.fulfill()
                } else {
                    XCTAssertFalse(syncStack.paginationToken.isEmpty)
                    XCTAssertTrue(syncStack.syncToken.isEmpty)
                    SyncAPITest.paginationToken = syncStack.paginationToken
                }
            case .failure(let error):
                XCTFail("\(error)")
                networkExpectation.fulfill()
            }
        })
        await fulfillment(of: [networkExpectation], timeout: 20)
    }

    func test01SyncInit() async {
        let networkExpectation = expectation(description: "Sync test exception")
        await sync(networkExpectation: networkExpectation)
    }

    func test02SyncToken() async {
        let syncStack = SyncStack(syncToken: SyncAPITest.syncToken)
        let networkExpectation = expectation(description: "Sync Token test exception")
        await sync(syncStack, networkExpectation: networkExpectation)
    }

    func test03SyncPagination() async {
        let syncStack = SyncStack(paginationToken: SyncAPITest.paginationToken)
        let networkExpectation = expectation(description: "Sync Pagination test exception")
        await sync(syncStack, networkExpectation: networkExpectation)
    }

    func test04SyncAssetPublished() async {
        let networkExpectation = expectation(description: "Sync Asset Publish test exception")
        await sync(syncTypes: [.publishType(.assetPublished)], networkExpectation: networkExpectation)
    }

    func test05SyncForContentType() async {
        let networkExpectation = expectation(description: "Sync ContentType test exception")
        await sync(syncTypes: [.contentType("session")], networkExpectation: networkExpectation)
    }

    func test06SyncLocale() async {
        let networkExpectation = expectation(description: "Sync Locale test exception")
        await sync(syncTypes: [.locale("en-gb")], networkExpectation: networkExpectation)
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

    func test08SyncContentTypeAndLocale() async {
        let networkExpectation = expectation(description: "Sync ContentType and Locale test exception")
        await sync(syncTypes: [.contentType("session"), .locale("en-us")],
             networkExpectation: networkExpectation)
    }
}
