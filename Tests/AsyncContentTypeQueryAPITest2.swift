//
//  AsyncContentTypeQueryAPITest2.swift
//  Contentstack iOS Tests
//
//  Created by Vikram Kalta on 02/01/2024.
//

import XCTest
@testable import Contentstack
import DVR

// var kContentTypeUID = ""
// var kContentTitle = ""

class AsyncContentTypeQueryAPITest2: XCTestCase {
    
    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "ContentType")
    
    func getContentType(uid: String? = nil) -> ContentType {
        return AsyncContentTypeQueryAPITest2.stack.contentType(uid: uid)
    }
    
    func getContentTypeQuery() -> ContentTypeQuery {
        return self.getContentType().query()
    }
    
    func asyncQueryWhere(_ key: ContentTypeModel.QueryableCodingKey, operation: Query.Operation) async -> ContentstackResponse<ContentTypeModel> {
        return try! await self.getContentTypeQuery().where(queryableCodingKey: key, operation).find() as ContentstackResponse<ContentTypeModel>
    }

    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    func test01FindAll_ContentTypeQuery() async {
        let networkExpectation = expectation(description: "Fetch All ContentTypes Test")
        let data: ContentstackResponse<ContentTypeModel> = try! await self.getContentTypeQuery().find()
        XCTAssertEqual(data.items.count, 11)
        if let contentType = data.items.first {
            kContentTypeUID = contentType.uid
            kContentTitle = contentType.title
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }

    func test02Find_ContentTypeQuery_whereUIDEquals() async {
        let networkExpectation = expectation(description: "Fetch where UID equals ContentTypes Test")
        let data: ContentstackResponse<ContentTypeModel> = await self.asyncQueryWhere(.uid, operation: .equals(kContentTypeUID))
        for contentType in data.items {
            XCTAssertEqual(contentType.uid, kContentTypeUID)
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test03Find_ContentTypeQuery_whereTitleDNotEquals() async {
        let networkExpectation = expectation(description: "Fetch where Title equals ContentTypes Test")
        let data: ContentstackResponse<ContentTypeModel> = await self.asyncQueryWhere(.title, operation: .notEquals(kContentTitle))
        for contentType in data.items {
            XCTAssertNotEqual(contentType.title, kContentTitle)
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test04Find_ContentTypeQuery_whereDescriptionexists() async {
        let networkExpectation = expectation(description: "Fetch where description exists ContentTypes Test")
        let data: ContentstackResponse<ContentTypeModel> = await self.asyncQueryWhere(.description, operation: .exists(true))
        XCTAssertEqual(data.items.count, 11)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test05Find_ContentTypeQuery_whereTitleMatchRegex() async {
        let networkExpectation = expectation(description: "Fetch where Title Match Regex ContentTypes Test")
        let data: ContentstackResponse<ContentTypeModel> = await self.asyncQueryWhere(.title, operation: .matches("Tr"))
        XCTAssertEqual(data.items.count, 1)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test06Fetch_ContentType_fromUID() async {
        let networkExpectation = expectation(description: "Fetch ContentTypes from UID Test")
        let data: ContentstackResponse<ContentTypeModel> = try! await self.getContentType(uid: kContentTypeUID).fetch()
        XCTAssertEqual(data.items.first?.uid, kContentTypeUID)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test07Fetch_ContentTypeQuery_WithGlobalFields() async {
        let networkExpectation = expectation(description: "Fetch ContentTypes with GlobalFields Test")
        let data: ContentstackResponse<ContentTypeModel> = try! await self.getContentTypeQuery().include(params: .globalFields).find()
        data.items.forEach { (model: ContentTypeModel) in
            model.schema.forEach { (schema) in
                if let dataType = schema["data_type"] as? String,
                   dataType == "global_field" {
                    kContentTypeUID = model.uid
                    XCTAssertNotNil(schema["schema"])
                }
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test08Fetch_ContentType_WithGlobalFields() async {
        let networkExpectation = expectation(description: "Fetch ContentTypes with GlobalFields Test")
        let data: ContentstackResponse<ContentTypeModel> = try! await self.getContentType(uid: kContentTypeUID).includeGlobalFields().fetch()
        data.items.first?.schema.forEach { (schema) in
            if let dataType = schema["data_type"] as? String,
               dataType == "global_field" {
                XCTAssertNotNil(schema["schema"])
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test09Fetch_ContentTypeQuery_WithCount() async {
        let networkExpectation = expectation(description: "Fetch ContentTypes with Count Test")
        let data: ContentstackResponse<ContentTypeModel> = try! await self.getContentTypeQuery().include(params: .count).find()
        XCTAssertEqual(data.count, 11)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test10Fetch_ContentType_WithWrongUID_shouldFail() async {
        let networkExpectation = expectation(description: "Fetch ContentTypes from wrong UID Test")
        do {
            let data: ContentstackResponse<ContentTypeModel> = try await self.getContentType(uid: "UID").fetch()
            XCTFail("UID should not be present")
        } catch {
            if let error = error as? APIError {
                XCTAssertEqual(error.errorCode, 118)
                XCTAssertEqual(error.errorMessage, "The Content Type 'UID' was not found. Please try again.")
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
}
