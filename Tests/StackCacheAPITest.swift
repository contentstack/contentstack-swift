//
//  StackCacheAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 21/04/20.
//

import XCTest
@testable import Contentstack
import DVR
#if os(iOS) || os(tvOS) || os(watchOS)
class StackCacheAPITest: XCTestCase {
    static let stack = TestContentstackClient.testCacheStack()

    func getEntry(uid: String? = nil) -> Entry {
        return StackCacheAPITest.stack.contentType(uid: "track").entry(uid: uid)
    }

    func getEntryQuery() -> Query {
        return self.getEntry().query()
    }
    
    override class func setUp() {
        super.setUp()
        URLCache.shared = CSURLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: "csio_cache")
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func test01GetCacheResponse() {
        let networkExpectation = expectation(description: "Fetch All Entry from cache Test")
        let query = getEntryQuery()
        query.cachePolicy = .cacheOnly
        query.find { (result: Result<ContentstackResponse<EntryModel>, Error>, responseType: ResponseType) in
            switch result {
            case .success:
                XCTAssertNotEqual(responseType, ResponseType.network)
                XCTFail("It should Fail.")
            case .failure(let error):
                XCTAssertEqual(responseType, ResponseType.cache)
                if let sdkError = error as? SDKError {
                    XCTAssertEqual(sdkError.message, "Failed to retreive data from Cache.")
                }
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 15)
    }

    func test02CacheThenNetwork_GetCacheFailuerThenNetworkResponse() {
        let networkExpectation = expectation(description: "Fetch All Entry Cache Then Network Get Cache Failuer Then Network Response Test")
        var responseCount = 2
        let query = getEntryQuery()
        query.cachePolicy = .cacheThenNetwork
        query.find { (result: Result<ContentstackResponse<EntryModel>, Error>, responseType: ResponseType) in
            responseCount-=1
            switch result {
            case .success(let contentstackResponse):
                if responseCount == 0 {
                    XCTAssertEqual(responseType, ResponseType.network)
                    XCTAssertEqual(contentstackResponse.items.count, 16)
                } else {
                    XCTFail("Should Fail At first")
                }
            case .failure(let error):
                XCTAssertEqual(responseType, ResponseType.cache)
                if responseCount == 1 {
                    if let sdkError = error as? SDKError {
                        XCTAssertEqual(sdkError.message, "Failed to retreive data from Cache.")
                    }
                } else {
                    XCTFail("\(error)")
                }
            }
            if responseCount == 0 {
                networkExpectation.fulfill()
            }
        }
        wait(for: [networkExpectation], timeout: 15)
    }

    func test03CacheThenNetwork_GetCachedThenNetworkResponse() {
        let networkExpectation = expectation(description: "Fetch All Entry from Cache Then Network Get Cached Then Network Response Test")
        let query = getEntryQuery()
        query.cachePolicy = .cacheThenNetwork
        var responseCount = 2
        query.find { (result: Result<ContentstackResponse<EntryModel>, Error>, responseType: ResponseType) in
            responseCount-=1
            switch result {
            case .success(let contentstackResponse):
                if responseCount == 0 {
                    XCTAssertEqual(responseType, ResponseType.network)
                    XCTAssertEqual(contentstackResponse.items.count, 16)
                } else {
                    XCTAssertEqual(responseType, ResponseType.cache)
                    XCTAssertEqual(contentstackResponse.items.count, 16)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            if responseCount == 0 {
                networkExpectation.fulfill()
            }
        }
        wait(for: [networkExpectation], timeout: 15)
    }
    
    func test04CacheElseNetwork_GetNetworkResponse() {
        let networkExpectation = expectation(description: "Fetch All Entry from cache Test")
        let query = getEntryQuery()
        query.cachePolicy = .cacheElseNetwork
        query
            .where(queryableCodingKey: .title, .matches("Ge"))
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, responseType: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(responseType, ResponseType.network)
                XCTAssertEqual(contentstackResponse.items.count, 1)
            case .failure(let error):
                XCTAssertEqual(responseType, ResponseType.network)
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 15)
    }

    func test05CacheElseNetwork_GetCacheResponse() {
        let networkExpectation = expectation(description: "Fetch All Entry from cache Test")
        let query = getEntryQuery()
        query.cachePolicy = .cacheElseNetwork
        query
            .where(queryableCodingKey: .title, .matches("Ge"))
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, responseType: ResponseType) in
                switch result {
                case .success(let contentstackResponse):
                    XCTAssertEqual(responseType, ResponseType.cache)
                    XCTAssertEqual(contentstackResponse.items.count, 1)
                case .failure(let error):
                    XCTAssertEqual(responseType, ResponseType.network)
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
            }
        wait(for: [networkExpectation], timeout: 15)
    }

    func test06NetworkElseCache_GetFailuer() {
        let networkExpectation = expectation(description: "Fetch Entry from Network Else Cache  Test")
        let entry = getEntry(uid: "TEST UOF")
        entry.cachePolicy = .networkElseCache
        entry
            .fetch { (result: Result<EntryModel, Error>, responseType: ResponseType) in
                switch result {
                case .success: break
                case .failure:
                    XCTAssertEqual(responseType, ResponseType.network)
                }
                networkExpectation.fulfill()
            }
        wait(for: [networkExpectation], timeout: 15)
    }
}
#endif
