//
//  EntryVariantsAPITest.swift
//  Contentstack
//

import XCTest
@testable import ContentstackSwift
import DVR

// MARK: - Stack factory (independent of the shared TestContentstackClient singleton)

private func makeVariantsStack(cassetteName: String) -> Stack {
    let config = TestContentstackClient.config()

    #if DEBUG
    // In DEBUG mode we hit the real server.
    // Requires config.json to have api_key, delivery_token, and environment set.
    guard let apiKey        = config["api_key"]        as? String,
          let deliveryToken = config["delivery_token"] as? String,
          let environment   = config["environment"]    as? String else {
        fatalError("EntryVariantsAPITest requires api_key, delivery_token, and environment in config.json")
    }
    return Contentstack.stack(apiKey: apiKey,
                               deliveryToken: deliveryToken,
                               environment: environment)
    #else
    // In non-DEBUG mode we replay through a DVR cassette.
    // Placeholder credentials match the cassette request headers.
    let stack = Contentstack.stack(apiKey: "api_key",
                                   deliveryToken: "delivery_token",
                                   environment: "environment",
                                   host: Host.delivery)
    let dvrSession = DVR.Session(cassetteName: cassetteName,
                                 backingSession: stack.urlSession)
    stack.urlSession = dvrSession
    return stack
    #endif
}

// MARK: - Test constants

private enum VariantConfig {
    private static let config = TestContentstackClient.config()

    static var contentTypeUID: String {
        guard let v = config["variants_content_type"] as? String else {
            fatalError("EntryVariantsAPITest requires variants_content_type in config.json")
        }
        return v
    }
    static var variantUID: String {
        guard let v = config["variant_uid"] as? String else {
            fatalError("EntryVariantsAPITest requires variant_uid in config.json")
        }
        return v
    }
    static var variantUIDs: [String] {
        guard let raw = config["variants_uid"] as? String else {
            fatalError("EntryVariantsAPITest requires variants_uid in config.json")
        }
        return raw.split(separator: ",").map { String($0) }
    }
    static var branchUID: String {
        guard let v = config["branch_uid"] as? String else {
            fatalError("EntryVariantsAPITest requires branch_uid in config.json")
        }
        return v
    }
}

// MARK: - API tests

class EntryVariantsAPITest: XCTestCase {
    static let stack = makeVariantsStack(cassetteName: "EntryVariants")

    // Captured from test01/test02 find() and used in test03/test04 fetch()
    static var kEntryUID = ""

    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    private func entry(uid: String? = nil) -> Entry {
        return EntryVariantsAPITest.stack
            .contentType(uid: VariantConfig.contentTypeUID)
            .entry(uid: uid)
    }

    private func entryQuery() -> Query {
        return entry().query()
    }

    // MARK: find() — entries list

    func test01Find_withSingleVariant() async {
        let expectation = expectation(description: "find() with single variant UID")
        entryQuery()
            .variants(uid: VariantConfig.variantUID)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, _: ResponseType) in
                switch result {
                case .success(let response):
                    XCTAssertFalse(response.items.isEmpty, "Expected at least one entry")
                    if let first = response.items.first {
                        EntryVariantsAPITest.kEntryUID = first.uid
                    }
                case .failure(let error):
                    XCTFail("find() with single variant failed: \(error)")
                }
                expectation.fulfill()
            }
        await fulfillment(of: [expectation], timeout: 30.0)
    }

    func test02Find_withMultipleVariantsAndBranch() async {
        let expectation = expectation(description: "find() with multiple variant UIDs and branch")
        entryQuery()
            .variants(uids: VariantConfig.variantUIDs, branch: VariantConfig.branchUID)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, _: ResponseType) in
                switch result {
                case .success(let response):
                    XCTAssertFalse(response.items.isEmpty, "Expected at least one entry")
                case .failure(let error):
                    XCTFail("find() with multiple variants + branch failed: \(error)")
                }
                expectation.fulfill()
            }
        await fulfillment(of: [expectation], timeout: 30.0)
    }

    // MARK: fetch() — single entry

    func test03Fetch_withSingleVariant() async {
        // Non-DEBUG: use the cassette UID. DEBUG: use whatever test01 captured.
        let uid: String
        #if DEBUG
        uid = EntryVariantsAPITest.kEntryUID
        #else
        uid = "blog_entry_uid_1"
        #endif
        guard !uid.isEmpty else {
            XCTFail("No entry UID available — test01 must run first")
            return
        }

        let expectation = expectation(description: "fetch() with single variant UID")
        entry(uid: uid)
            .variants(uid: VariantConfig.variantUID)
            .fetch { (result: Result<EntryModel, Error>, _: ResponseType) in
                switch result {
                case .success(let model):
                    XCTAssertEqual(model.uid, uid)
                case .failure(let error):
                    XCTFail("fetch() with single variant failed: \(error)")
                }
                expectation.fulfill()
            }
        await fulfillment(of: [expectation], timeout: 30.0)
    }

    func test04Fetch_withMultipleVariantsAndBranch() async {
        let uid: String
        #if DEBUG
        uid = EntryVariantsAPITest.kEntryUID
        #else
        uid = "blog_entry_uid_1"
        #endif
        guard !uid.isEmpty else {
            XCTFail("No entry UID available — test01 must run first")
            return
        }

        let expectation = expectation(description: "fetch() with multiple variant UIDs and branch")
        entry(uid: uid)
            .variants(uids: VariantConfig.variantUIDs, branch: VariantConfig.branchUID)
            .fetch { (result: Result<EntryModel, Error>, _: ResponseType) in
                switch result {
                case .success(let model):
                    XCTAssertEqual(model.uid, uid)
                case .failure(let error):
                    XCTFail("fetch() with multiple variants + branch failed: \(error)")
                }
                expectation.fulfill()
            }
        await fulfillment(of: [expectation], timeout: 30.0)
    }
}
