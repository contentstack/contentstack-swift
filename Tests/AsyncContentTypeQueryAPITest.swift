//
//  AsyncContentTypeQueryAPITest.swift
//  Contentstack
//
//  Created by Jigar Kanani on 20/10/23.
//

import XCTest
@testable import Contentstack
import DVR

class AsyncContentTypeQueryAPITest: XCTestCase {

    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "ContentType")
    
    func getContentType(uid: String? = nil) -> ContentType {
        return AsyncContentTypeQueryAPITest.stack.contentType(uid: uid)
    }
    
    func getContentTypeQuery() -> ContentTypeQuery {
        return self.getContentType().query()
    }
    
    func asyncQueryWhere(_ key: ContentTypeModel.QueryableCodingKey, operation: Query.Operation, then completion: @escaping ((Result<ContentstackResponse<ContentTypeModel>, Error>) -> ())) async {
        await self.getContentTypeQuery().where(queryableCodingKey: key, operation)
            .asyncFind { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, responseType) in
                completion(result)
        }
    }
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func test01FindAll_ContentTypeQuery() async {
        let networkExpectation = expectation(description: "Fetch All ContentTypes Test")
        await self.getContentTypeQuery().asyncFind { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 11)
                if let contentType = contentstackResponse.items.first {
                    kContentTypeUID = contentType.uid
                    kContentTitle = contentType.title
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test02Find_ContentTypeQuery_whereUIDEquals() async {
        let networkExpectation = expectation(description: "Fetch where UID equals ContentTypes Test")
        await self.asyncQueryWhere(.uid, operation: .equals(kContentTypeUID)) { (result: Result<ContentstackResponse<ContentTypeModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for contentType in contentstackResponse.items {
                    XCTAssertEqual(contentType.uid, kContentTypeUID)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test03Find_ContentTypeQuery_whereTitleDNotEquals() async {
        let networkExpectation = expectation(description: "Fetch where Title equals ContentTypes Test")
        await self.asyncQueryWhere(.title, operation: .notEquals(kContentTitle)) { (result: Result<ContentstackResponse<ContentTypeModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for contentType in contentstackResponse.items {
                    XCTAssertNotEqual(contentType.title, kContentTitle)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test04Find_ContentTypeQuery_whereDescriptionexists() async {
        let networkExpectation = expectation(description: "Fetch where description exists ContentTypes Test")
        await self.asyncQueryWhere(.description, operation: .exists(true)) { (result: Result<ContentstackResponse<ContentTypeModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 11)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test05Find_ContentTypeQuery_whereTitleMatchRegex() async {
        let networkExpectation = expectation(description: "Fetch where Title Match Regex ContentTypes Test")
        await self.asyncQueryWhere(.title, operation: .matches("Tr")) { (result: Result<ContentstackResponse<ContentTypeModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 1)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test06Fetch_ContentType_fromUID() async {
        let networkExpectation = expectation(description: "Fetch ContentTypes from UID Test")
        await self.getContentType(uid: kContentTypeUID).asyncFetch { (result: Result<ContentTypeModel, Error>, response: ResponseType) in
            switch result {
            case .success(let model):
                XCTAssertEqual(model.uid, kContentTypeUID)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test07Fetch_ContentTypeQuery_WithGlobalFields() async {
        let networkExpectation = expectation(description: "Fetch ContentTypes with GLobalFields Test")
        await self.getContentTypeQuery()
            .include(params: .globalFields)
            .asyncFind { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let contentstackResponse):
                    contentstackResponse.items.forEach { (model: ContentTypeModel) in
                        model.schema.forEach { (schema) in
                            if let dataType = schema["data_type"] as? String,
                                dataType == "global_field" {
                                kContentTypeUID = model.uid
                                XCTAssertNotNil(schema["schema"])
                            }
                        }
                    }
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)

    }
    
    func test08Fetch_ContentType_WithGlobalFields() async {
        let networkExpectation = expectation(description: "Fetch ContentTypes with GlobalFields Test")
        await self.getContentType(uid: kContentTypeUID)
            .includeGlobalFields()
            .asyncFetch { (result: Result<ContentTypeModel, Error>, response: ResponseType) in
                switch result {
                case .success(let model):
                    model.schema.forEach { (schema) in
                        if let dataType = schema["data_type"] as? String,
                            dataType == "global_field" {
                            XCTAssertNotNil(schema["schema"])
                        }
                    }
                case .failure(let error):
                    XCTFail("\(error)")
                }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test09Fetch_ContentTypeQuery_WithCount() async {
        let networkExpectation = expectation(description: "Fetch ContentTypes with Count Test")
        await self.getContentTypeQuery()
            .include(params: .count)
            .asyncFind { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let contentstackResponse):
                    XCTAssertEqual(contentstackResponse.count, 11)
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)

    }

    func test11Fetch_ContentType_WithWrongUID_shouldFail() async {
         let networkExpectation = expectation(description: "Fetch ContentTypes from wrong UID Test")
        await self.getContentType(uid: "UID").asyncFetch { (result: Result<ContentTypeModel, Error>, response: ResponseType) in
            switch result {
            case .success:
                XCTFail("UID should not be present")
            case .failure(let error):
                if let error = error as? APIError {
                    XCTAssertEqual(error.errorCode, 118)
                    XCTAssertEqual(error.errorMessage, "The Content Type 'UID' was not found. Please try again.")
                }
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
}
