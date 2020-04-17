//
//  ContentTypeAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 09/04/20.
//

import XCTest
@testable import Contentstack
import DVR
var kEntryUID = "blta61ff479ff8f7c18"
var kEntryTitle = ""
class EntryAPITest: XCTestCase {
    static let stack = TestContentstackClient.testStack(cassetteName: "Entry")

    func getEntry(uid: String? = nil) -> Entry {
        return EntryAPITest.stack.contentType(uid: "session").entry(uid: uid)
    }

    func getEntryQuery() -> Query {
        return self.getEntry().query()
    }
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func queryWhere(_ key: EntryModel.FieldKeys, operation: Query.Operation, then completion: @escaping ((Result<ContentstackResponse<EntryModel>, Error>) -> ())) {
        self.getEntryQuery().where(queryableCodingKey: key, operation)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, responseType) in
                completion(result)
        }
    }

    func test01FindAll_EntryQuery() {
        let networkExpectation = expectation(description: "Fetch All Entry Test")
        self.getEntryQuery().find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 31)
                if let entry = contentstackResponse.items.first {
                    kEntryUID = entry.uid
                    kEntryTitle = entry.title
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test02Find_EntryQuery_whereUIDEquals() {
        let networkExpectation = expectation(description: "Fetch where UID equals Entry Test")
        self.queryWhere(.uid, operation: .equals(kEntryUID)) { (result: Result<ContentstackResponse<EntryModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for entry in contentstackResponse.items {
                    XCTAssertEqual(entry.uid, kEntryUID)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test03Find_EntryQuery_whereTitleDNotEquals() {
        let networkExpectation = expectation(description: "Fetch where Title equals Entry Test")
        self.queryWhere(.title, operation: .notEquals(kEntryTitle)) { (result: Result<ContentstackResponse<EntryModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for entry in contentstackResponse.items {
                    XCTAssertNotEqual(entry.title, kEntryTitle)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test04Find_EntryQuery_whereTitleexists() {
        let networkExpectation = expectation(description: "Fetch where Title exists Entry Test")
        self.queryWhere(.title, operation: .exists(true)) { (result: Result<ContentstackResponse<EntryModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 31)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test05Find_EntryQuery_whereTitleMatchRegex() {
        let networkExpectation = expectation(description: "Fetch where Title Match Regex Entry Test")
        self.queryWhere(.title, operation: .matches("Tr")) { (result: Result<ContentstackResponse<EntryModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 2)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test06Fetch_Entry_fromUID() {
        let networkExpectation = expectation(description: "Fetch Entry from UID Test")
        self.getEntry(uid: kEntryUID).fetch { (restult: Result<EntryModel, Error>, response: ResponseType) in
            switch restult {
            case .success(let model):
                XCTAssertEqual(model.uid, kEntryUID)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test07Fetch_EntryQuery_WithIncludeContentType() {
        let networkExpectation = expectation(description: "Fetch Entry Query with include ContentType Test")
        self.getEntryQuery()
            .include(params: .contentType)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let contentstackResponse):
                    XCTAssertNotNil(contentstackResponse.fields?["content_type"])
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)

    }
    
    func test08Fetch_Entry_WithGlobalFields() {
        let networkExpectation = expectation(description: "Fetch Entry with GlobalFields Test")
        self.getEntry(uid: kEntryUID)
            .include(params: .globalField)
            .fetch { (restult: Result<EntryModel, Error>, response: ResponseType) in
                switch restult {
                case .success(let model):
                    if let contentType = model.contentType {
                        contentType.schema.forEach { (schema) in
                            if let dataType = schema["data_type"] as? String,
                                dataType == "global_field" {
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
    
    func test09Fetch_EntryQuery_WithCount() {
        let networkExpectation = expectation(description: "Fetch Entry with Count Test")
        self.getEntryQuery()
            .include(params: .count)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let contentstackResponse):
                    XCTAssertEqual(contentstackResponse.count, 31)
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)

    }

    func test10Fetch_Entry_WithIncludeContentType() {
        let networkExpectation = expectation(description: "Fetch Entry with include ContentType Test")
        self.getEntry(uid: kEntryUID)
            .include(params: .contentType)
            .fetch { (result: Result<EntryModel, Error>, response: ResponseType) in
                switch result {
                case .success(let model):
                    XCTAssertNotNil(model.contentType)
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test11Fetch_Entry_WithWrongUID_shouldFail() {
         let networkExpectation = expectation(description: "Fetch Entry from wrong UID Test")
        self.getEntry(uid: "UID").fetch { (restult: Result<EntryModel, Error>, response: ResponseType) in
            switch restult {
            case .success:
                XCTFail("UID should not be present")
            case .failure(let error):
                if let error = error as? APIError {
                    XCTAssertEqual(error.errorCode, 141)
                    XCTAssertEqual(error.errorMessage, "The requested object doesn't exist.")
                }
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test12Fetch_EntryQuery_WithGlobalFields() {
        let networkExpectation = expectation(description: "Fetch Entry Query with GlobalFields Test")
        self.getEntryQuery()
            .include(params: .globalField)
            .find { (restult: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
                switch restult {
                case .success(let model):
                    if let contentType = model.fields?["content_type"] as? ContentTypeModel {
                        contentType.schema.forEach { (schema) in
                            if let dataType = schema["data_type"] as? String,
                                dataType == "global_field" {
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

    func test13Find_EntryQuery_whereTitleIncludes() {
        let titleArray = ["Management Strategy and Roadmap", "The Cloud is Over The Top"]
        let networkExpectation = expectation(description: "Fetch where Title Include Entry Test")
        self.queryWhere(.title, operation: .includes(titleArray)) { (result: Result<ContentstackResponse<EntryModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 2)
                for entry in contentstackResponse.items {
                    if !titleArray.contains(entry.title) {
                        XCTFail("Entry title \(entry.title) does not match")
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test14Find_EntryQuery_whereTitleExclude() {
        let titleArray = ["Management Strategy and Roadmap", "The Cloud is Over The Top"]
        let networkExpectation = expectation(description: "Fetch where Title Exclude Entry Test")
        self.queryWhere(.title, operation: .excludes(titleArray)) { (result: Result<ContentstackResponse<EntryModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 29)
                for entry in contentstackResponse.items {
                    if titleArray.contains(entry.title) {
                        XCTFail("Entry title \(entry.title) should not match")
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test15Find_EntryQuery_wherelessThan() {
        let formatter = Date.iso8601Formatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date = formatter.date(from: "2018-08-27T12:30:00.000Z")!
        
        let networkExpectationDate = expectation(description: "Fetch where Session Time less than Date Test")
        self.getEntryQuery().where(valueAtKey: "session_time.strart_time", .isLessThan(date)).find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 29)
                for entry in contentstackResponse.items {
                    if let sessionTime = entry.fields?["session_time"] as? [String: Any],
                        let Date = sessionTime["strart_time"] as? String,
                        let startDate = formatter.date(from: Date) {
                        XCTAssertLessThan(startDate, date)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectationDate.fulfill()
        }
        let id = 2493
        let networkExpectation = expectation(description: "Fetch where Session ID less than Number Test")
        self.getEntryQuery().where(valueAtKey: "session_id", .isLessThan(id)).find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 7)
                for entry in contentstackResponse.items {
                    if let sessionid = entry.fields?["session_id"] as? Int {
                        XCTAssertLessThan(sessionid, id)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation, networkExpectationDate], timeout: 5)
    }
}
