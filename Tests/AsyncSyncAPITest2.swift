//
//  AsyncSyncAPITest2.swift
//  Contentstack iOS Tests
//
//  Created by Vikram Kalta on 09/01/2024.
//

import XCTest
@testable import Contentstack
import DVR

class AsyncSyncAPITest2: XCTestCase {
    
    static var paginationToken = ""
    static var syncToken = ""
    
    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "SyncTest")

    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func sync(_ syncStack: SyncStack = SyncStack(), syncTypes: [SyncStack.SyncableTypes] = [.all], networkExpectation: XCTestExpectation) async throws -> Result<SyncStack, Error> {
        do {
            let syncStream = try await AsyncSyncAPITest2.stack.sync(syncStack, syncTypes: syncTypes)
            for try await data in syncStream {
                return .success(data)
            }
            return .success(syncStack)
        } catch {
            networkExpectation.fulfill()
            return .failure(error)
        }
    }
    
    func test01SyncInit() async {
                let networkExpectation = expectation(description: "Sync test exception")
        let syncStack: SyncStack = SyncStack()
        let syncTypes: [SyncStack.SyncableTypes] = [.all]
        do {
            let syncStream = try await AsyncSyncAPITest2.stack.sync(syncStack, syncTypes: syncTypes)
            for try await data in syncStream {
                if !data.hasMorePages {
                    XCTAssertEqual(data.items.count, 29)
                    XCTAssertFalse(data.syncToken.isEmpty)
                    XCTAssertTrue(data.paginationToken.isEmpty)
                    AsyncSyncAPITest2.syncToken = data.syncToken
                } else {
                    XCTAssertEqual(data.items.count, 100)
                    XCTAssertFalse(data.paginationToken.isEmpty)
                    XCTAssertTrue(data.syncToken.isEmpty)
                    AsyncSyncAPITest2.paginationToken = data.paginationToken
                }
            }
        } catch {
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 10)
    }
    
    func test02SyncToken() async {
        let syncStack = SyncStack(syncToken: AsyncSyncAPITest2.syncToken)
        let syncTypes: [SyncStack.SyncableTypes] = [.all]
        let networkExpectation = expectation(description: "Sync Token test exception")
        do {
            let syncStream = try await AsyncSyncAPITest2.stack.sync(syncStack, syncTypes: syncTypes)
            for try await data in syncStream {
                if !data.hasMorePages {
                    XCTAssertEqual(syncStack.items.count, 0)
                    XCTAssertFalse(syncStack.syncToken.isEmpty)
                    XCTAssertTrue(syncStack.paginationToken.isEmpty)
                }
            }
        } catch {
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 10)
    }

    func test03SyncPagination() async {
        let syncStack = SyncStack(paginationToken: AsyncSyncAPITest2.paginationToken)
        let networkExpectation = expectation(description: "Sync Pagination test exception")
        do {
            let syncStream = try await AsyncSyncAPITest2.stack.sync(syncStack)
            for try await data in syncStream {
                if !data.hasMorePages {
                    XCTAssertEqual(data.items.count, 29)
                    XCTAssertFalse(data.syncToken.isEmpty)
                    XCTAssertTrue(data.paginationToken.isEmpty)
                }
            }
        } catch {
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 10)
    }

    func test04SyncAssetPublished() async {
        let networkExpectation = expectation(description: "Sync Asset Publish test exception")
        do {
            let syncStream = try await AsyncSyncAPITest2.stack.sync(syncTypes: [.publishType(.assetPublished)])
            for try await data in syncStream {
                XCTAssertEqual(data.items.count, 9)
                XCTAssertFalse(data.syncToken.isEmpty)
                XCTAssertTrue(data.paginationToken.isEmpty)
            }
        } catch {
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 10)
    }
   
    func test05SyncForContentType() async {
        let networkExpectation = expectation(description: "Sync ContentType test exception")
        do {
            let syncStream = try await AsyncSyncAPITest2.stack.sync(syncTypes: [.contentType("session")])
            for try await data in syncStream {
                XCTAssertEqual(data.items.count, 32)
                XCTAssertFalse(data.syncToken.isEmpty)
                XCTAssertTrue(data.paginationToken.isEmpty)
            }
        } catch {
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 10)
    }

    func test06SyncLocale() async {
        let networkExpectation = expectation(description: "Sync Locale test exception")
        do {
            let syncStream = try await AsyncSyncAPITest2.stack.sync(syncTypes: [.locale("en-gb")])
            for try await data in syncStream {
                XCTAssertEqual(data.items.count, 6)
                XCTAssertFalse(data.syncToken.isEmpty)
                XCTAssertTrue(data.paginationToken.isEmpty)
            }
        } catch {
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 10)
    }
  
    func test07SyncFromStartDate() async {
        let networkExpectation = expectation(description: "Sync Start From Date test exception")
        let date = "2020-04-29T08:05:56Z".iso8601StringDate!
        do {
            let syncStream = try await AsyncSyncAPITest2.stack.sync(syncTypes: [.startFrom(date)])
            for try await data in syncStream {
                XCTAssertEqual(data.items.count, 6)
                XCTAssertFalse(data.syncToken.isEmpty)
                XCTAssertTrue(data.paginationToken.isEmpty)
            }
        } catch {
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 10)
    }

    func test08SyncContentTypeAndLocale() async {
        let networkExpectation = expectation(description: "Sync ContentType and Locale test exception")
        do {
            let syncStream = try await AsyncSyncAPITest2.stack.sync(syncTypes: [.contentType("session"), .locale("en-us")])
            for try await data in syncStream {
                XCTAssertEqual(data.items.count, 31)
                XCTAssertFalse(data.syncToken.isEmpty)
                XCTAssertTrue(data.paginationToken.isEmpty)
            }
        } catch {
            XCTFail("\(error)")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 10)
    }
}
