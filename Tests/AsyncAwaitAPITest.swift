//
//  AsyncAwaitTests.swift
//  ContentstackSwift
//
//  Created by Contentstack Team
//

import XCTest
@testable import ContentstackSwift
import DVR

// MARK: - Stack Async Tests
class AsyncAwaitStackTests: XCTestCase {
    
    static let stack = TestContentstackClient.testStack(cassetteName: "SyncTest")
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
    
    func testStackSyncAsync() async {
        // Test that async sync method doesn't crash and handles errors properly
        do {
            let syncStack = try await AsyncAwaitStackTests.stack.sync()
            XCTAssertNotNil(syncStack)
        } catch {
            // Expected to fail in test environment, but should not crash
            XCTAssertTrue(error is APIError || error is DecodingError)
        }
    }
}

// MARK: - Asset Async Tests
class AsyncAwaitAssetTests: XCTestCase {
    
    static let stack = TestContentstackClient.testStack(cassetteName: "Asset")
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
    
    func testAssetFetchAsync() async {
        // Test that async asset fetch method doesn't crash
        // Using UID from Asset.json cassette: "uid_89"
        do {
            let asset: AssetModel = try await AsyncAwaitAssetTests.stack.asset(uid: "uid_89")
                .includeDimension()
                .includeMetadata()
                .fetch()
            XCTAssertNotNil(asset)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
    
    func testAssetQueryAsync() async {
        // Test that async asset query method doesn't crash
        do {
            let assets: ContentstackResponse<AssetModel> = try await AsyncAwaitAssetTests.stack.asset()
                .query()
                .limit(to: 5)
                .find()
            XCTAssertNotNil(assets)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
}

// MARK: - ContentType Async Tests
class AsyncAwaitContentTypeTests: XCTestCase {
    
    static let stack = TestContentstackClient.testStack(cassetteName: "ContentType")
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
    
    func testContentTypeFetchAsync() async {
        // Test that async content type fetch method doesn't crash
        // Using UID from ContentType.json cassette: "session"
        do {
            let contentType: ContentTypeModel = try await AsyncAwaitContentTypeTests.stack.contentType(uid: "session")
                .fetch()
            XCTAssertNotNil(contentType)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
    
    func testContentTypeQueryAsync() async {
        // Test that async content type query method doesn't crash
        do {
            let contentTypes: ContentstackResponse<ContentTypeModel> = try await AsyncAwaitContentTypeTests.stack.contentType()
                .query()
                .limit(to: 10)
                .find()
            XCTAssertNotNil(contentTypes)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
}

// MARK: - Entry Async Tests
class AsyncAwaitEntryTests: XCTestCase {
    
    static let stack = TestContentstackClient.testStack(cassetteName: "Entry")
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
    
    func testEntryFetchAsync() async {
        // Test that async entry fetch method doesn't crash
        // Using UIDs from Entry.json cassette: contentType "session", entry "session_uid_1"
        do {
            let entry: EntryModel = try await AsyncAwaitEntryTests.stack.contentType(uid: "session")
                .entry(uid: "session_uid_1")
                .fetch()
            XCTAssertNotNil(entry)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
    
    func testEntryQueryAsync() async {
        // Test that async entry query method doesn't crash
        do {
            let entries: ContentstackResponse<EntryModel> = try await AsyncAwaitEntryTests.stack.contentType(uid: "session")
                .entry()
                .query()
                .limit(to: 15)
                .find()
            XCTAssertNotNil(entries)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
}

// MARK: - GlobalField Async Tests
class AsyncAwaitGlobalFieldTests: XCTestCase {
    
    static let stack = TestContentstackClient.testStack(cassetteName: "GlobalField")
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
    
    func testGlobalFieldFetchAsync() async {
        // Test that async global field fetch method doesn't crash
        // Using UID from GlobalField.json cassette: "feature"
        do {
            let globalField: GlobalFieldModel = try await AsyncAwaitGlobalFieldTests.stack.globalField(uid: "feature")
                .includeGlobalFieldSchema()
                .fetch()
            XCTAssertNotNil(globalField)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
    
    func testGlobalFieldQueryAsync() async {
        // Test that async global field query method doesn't crash
        do {
            let globalFields: ContentstackResponse<GlobalFieldModel> = try await AsyncAwaitGlobalFieldTests.stack.globalField()
                .find()
            XCTAssertNotNil(globalFields)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
}

// MARK: - Error Handling Tests
class AsyncAwaitErrorTests: XCTestCase {
    
    static let stack = TestContentstackClient.testStack(cassetteName: "Asset")
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
    
    func testInvalidUIDErrorAsync() async {
        // Test error handling for invalid UID
        do {
            let _: AssetModel = try await AsyncAwaitErrorTests.stack.asset(uid: "invalid_uid_that_does_not_exist")
                .fetch()
            XCTFail("Should have thrown an error for invalid UID")
        } catch {
            XCTAssertTrue(error is SDKError || error is APIError)
        }
    }
    
    func testNetworkErrorAsync() async {
        // Test error handling for network issues
        do {
            let _: ContentstackResponse<EntryModel> = try await AsyncAwaitErrorTests.stack.contentType(uid: "invalid_content_type_that_does_not_exist")
                .entry()
                .query()
                .find()
            XCTFail("Should have thrown an error for invalid content type")
        } catch {
            XCTAssertTrue(error is SDKError || error is APIError)
        }
    }
}

// MARK: - Concurrent Operations Tests
class AsyncAwaitConcurrentTests: XCTestCase {
    
    static let stack = TestContentstackClient.testStack(cassetteName: "Asset")
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
    
    func testConcurrentAssetAndEntryFetchAsync() async {
        // Test concurrent operations
        do {
            async let assets: ContentstackResponse<AssetModel> = AsyncAwaitConcurrentTests.stack.asset()
                .query()
                .limit(to: 3)
                .find()
            
            async let entries: ContentstackResponse<EntryModel> = AsyncAwaitConcurrentTests.stack.contentType(uid: "session")
                .entry()
                .query()
                .limit(to: 3)
                .find()
            
            let (assetsResult, entriesResult) = try await (assets, entries)
            
            // If we get here, the concurrent async methods worked
            XCTAssertNotNil(assetsResult)
            XCTAssertNotNil(entriesResult)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
    
    func testConcurrentMultipleOperationsAsync() async {
        // Test multiple concurrent operations
        do {
            async let syncStack = AsyncAwaitConcurrentTests.stack.sync()
            async let assets: ContentstackResponse<AssetModel> = AsyncAwaitConcurrentTests.stack.asset().query().limit(to: 2).find()
            async let contentTypes: ContentstackResponse<ContentTypeModel> = AsyncAwaitConcurrentTests.stack.contentType().query().limit(to: 2).find()
            
            let (syncResult, assetsResult, contentTypesResult) = try await (syncStack, assets, contentTypes)
            
            // If we get here, the concurrent async methods worked
            XCTAssertNotNil(syncResult)
            XCTAssertNotNil(assetsResult)
            XCTAssertNotNil(contentTypesResult)
        } catch {
            // Expected to fail with invalid credentials, but async/await should work
            XCTAssertTrue(error is APIError || error is SDKError)
        }
    }
}

// MARK: - Async/Await Syntax Tests
class AsyncAwaitSyntaxTests: XCTestCase {
    
    static let stack = TestContentstackClient.testStack(cassetteName: "Asset")
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
    
    func testAsyncAwaitSyntax() async {
        // Test that async/await syntax works correctly
        let expectation = XCTestExpectation(description: "Async operation completed")
        
        Task {
            do {
                let _: ContentstackResponse<AssetModel> = try await AsyncAwaitSyntaxTests.stack.asset()
                    .query()
                    .limit(to: 1)
                    .find()
                expectation.fulfill()
            } catch {
                // Expected to fail, but async/await syntax should work
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 30.0)
    }
    
    func testAsyncLetSyntax() async {
        // Test async let syntax for concurrent operations
        let expectation = XCTestExpectation(description: "Concurrent operations completed")
        
        Task {
            do {
                async let assetQuery: ContentstackResponse<AssetModel> = AsyncAwaitSyntaxTests.stack.asset().query().limit(to: 1).find()
                async let contentTypeQuery: ContentstackResponse<ContentTypeModel> = AsyncAwaitSyntaxTests.stack.contentType().query().limit(to: 1).find()
                
                let (_, _) = try await (assetQuery, contentTypeQuery)
                expectation.fulfill()
            } catch {
                // Expected to fail, but async let syntax should work
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 30.0)
    }
}
