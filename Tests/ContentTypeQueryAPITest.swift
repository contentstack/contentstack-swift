//
//  ContentTypeAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 08/04/20.
//

import XCTest
@testable import Contentstack
import DVR
var kContentTypeUID = ""
var kContetnTitle = ""

class ContentTypeQueryAPITest: XCTestCase {

    static let stack = TestContentstackClient.testStack(cassetteName: "ContentType")
    
    func getContentType(uid: String? = nil) -> ContentType {
        return ContentTypeQueryAPITest.stack.contentType(uid: uid)
    }
    
    func getContentTypeQuery() -> ContentTypeQuery {
        return self.getContentType().query()
    }
    
    func queryWhere(_ key: ContentTypeModel.QueryableCodingKey, operation: Query.Operation, then completion: @escaping ((Result<ContentstackResponse<ContentTypeModel>, Error>) -> ())) {
        self.getContentTypeQuery().where(queryableCodingKey: key, operation)
            .find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, responseType) in
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

    func test01FindAll_ContentTypeQuery() {
        let networkExpectation = expectation(description: "Fetch All ContentTypes Test")
        self.getContentTypeQuery().find { (result: Result<ContentstackResponse<ContentTypeModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 11)
                if let contentType = contentstackResponse.items.first {
                    kContentTypeUID = contentType.uid
                    kContetnTitle = contentType.title
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test02Find_ContentTypeQuery_whereUIDEquals() {
        let networkExpectation = expectation(description: "Fetch where UID equals ContentTypes Test")
        self.queryWhere(.uid, operation: .equals(kContentTypeUID)) { (result: Result<ContentstackResponse<ContentTypeModel>, Error>) in
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
    
    func test03Find_ContentTypeQuery_whereTitleDNotEquals() {
        let networkExpectation = expectation(description: "Fetch where Title equals ContentTypes Test")
        self.queryWhere(.title, operation: .notEquals(kContetnTitle)) { (result: Result<ContentstackResponse<ContentTypeModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for contentType in contentstackResponse.items {
                    XCTAssertNotEqual(contentType.title, kContetnTitle)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test04Find_ContetnTypeQuery_whereDescriptionexists() {
        let networkExpectation = expectation(description: "Fetch where description exists ContentTypes Test")
        self.queryWhere(.description, operation: .exists(true)) { (result: Result<ContentstackResponse<ContentTypeModel>, Error>) in
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
    
    func test05Find_ContetnTypeQuery_whereTitleMatchRegex() {
        let networkExpectation = expectation(description: "Fetch where Title Match Regex ContentTypes Test")
        self.queryWhere(.title, operation: .matches("Tr")) { (result: Result<ContentstackResponse<ContentTypeModel>, Error>) in
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

    func test06Fetch_ContentType_fromUID() {
        let networkExpectation = expectation(description: "Fetch ContentTypes from UID Test")
        self.getContentType(uid: kContentTypeUID).fetch { (restult: Result<ContentTypeModel, Error>, response: ResponseType) in
            switch restult {
            case .success(let model):
                XCTAssertEqual(model.uid, kContentTypeUID)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
}
