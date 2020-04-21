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
        self.getEntry(uid: "UID")
            .fetch { (restult: Result<EntryModel, Error>, response: ResponseType) in
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
        self.getEntryQuery().where(valueAtKey: "session_time.start_time", .isLessThan(date)).find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 29)
                for entry in contentstackResponse.items {
                    if let sessionTime = entry.fields?["session_time"] as? [String: Any],
                        let Date = sessionTime["start_time"] as? String,
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
    
    func test16Find_EntryQuery_wherelessThanEqual() {
        let formatter = Date.iso8601Formatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date = formatter.date(from: "2018-08-27T12:30:00.000Z")!
        
        let networkExpectationDate = expectation(description: "Fetch where Session Time less than Or equal Date Test")
        self.getEntryQuery().where(valueAtKey: "session_time.start_time", .isLessThanOrEqual(date)).find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 29)
                for entry in contentstackResponse.items {
                    if let sessionTime = entry.fields?["session_time"] as? [String: Any],
                        let Date = sessionTime["start_time"] as? String,
                        let startDate = formatter.date(from: Date) {
                        XCTAssertLessThanOrEqual(startDate, date)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectationDate.fulfill()
        }
        let id = 2493
        let networkExpectation = expectation(description: "Fetch where Session ID less than Or equal Number Test")
        self.getEntryQuery().where(valueAtKey: "session_id", .isLessThanOrEqual(id)).find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 8)
                for entry in contentstackResponse.items {
                    if let sessionid = entry.fields?["session_id"] as? Int {
                        XCTAssertLessThanOrEqual(sessionid, id)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation, networkExpectationDate], timeout: 5)
    }
    
    func test17Find_EntryQuery_whereGreaterThan() {
        let formatter = Date.iso8601Formatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date = formatter.date(from: "2018-08-27T12:30:00.000Z")!
        
        let networkExpectationDate = expectation(description: "Fetch where Session Time Greater than Date Test")
        self.getEntryQuery().where(valueAtKey: "session_time.start_time", .isGreaterThan(date)).find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 2)
                for entry in contentstackResponse.items {
                    if let sessionTime = entry.fields?["session_time"] as? [String: Any],
                        let Date = sessionTime["start_time"] as? String,
                        let startDate = formatter.date(from: Date) {
                        XCTAssertGreaterThan(startDate, date)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectationDate.fulfill()
        }
        let id = 2493
        let networkExpectation = expectation(description: "Fetch where Session ID Greater than Number Test")
        self.getEntryQuery().where(valueAtKey: "session_id", .isGreaterThan(id)).find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 23)
                for entry in contentstackResponse.items {
                    if let sessionid = entry.fields?["session_id"] as? Int {
                        XCTAssertGreaterThan(sessionid, id)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation, networkExpectationDate], timeout: 5)
    }

    func test18Find_EntryQuery_whereGreaterThanEqual() {
        let formatter = Date.iso8601Formatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date = formatter.date(from: "2018-08-27T12:30:00.000Z")!
        
        let networkExpectationDate = expectation(description: "Fetch where Session Time Greater than or Equal Date Test")
        self.getEntryQuery().where(valueAtKey: "session_time.start_time", .isGreaterThanOrEqual(date)).find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 2)
                for entry in contentstackResponse.items {
                    if let sessionTime = entry.fields?["session_time"] as? [String: Any],
                        let Date = sessionTime["start_time"] as? String,
                        let startDate = formatter.date(from: Date) {
                        XCTAssertGreaterThanOrEqual(startDate, date)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectationDate.fulfill()
        }
        let id = 2493
        let networkExpectation = expectation(description: "Fetch where Session ID Greater than or Equal Number Test")
        self.getEntryQuery().where(valueAtKey: "session_id", .isGreaterThanOrEqual(id)).find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 24)
                for entry in contentstackResponse.items {
                    if let sessionid = entry.fields?["session_id"] as? Int {
                        XCTAssertGreaterThanOrEqual(sessionid, id)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation, networkExpectationDate], timeout: 5)
    }

    func test19Find_EntryQuery_OrderBySessionTime() {
        let networkExpectation = expectation(description: "Fetch Order by Ascending Start Time Test")
        let formatter = Date.iso8601Formatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

        self.getEntryQuery()
            .orderByAscending(keyPath: "session_time.start_time")
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                var date: Date?
                for entry in contentstackResponse.items {
                    if let sessionTime = entry.fields?["session_time"] as? [String: Any],
                        let Date = sessionTime["start_time"] as? String,
                        let startDate = formatter.date(from: Date) {
                        if let oldDate = date {
                            XCTAssertGreaterThanOrEqual(startDate, oldDate)
                        }
                        date = startDate
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        let networkExpectationDesc = expectation(description: "Fetch Order by Ascending Start Time Test")

        self.getEntryQuery()
            .orderByDecending(keyPath: "session_time.end_time")
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                var date: Date?
                for entry in contentstackResponse.items {
                    if let sessionTime = entry.fields?["session_time"] as? [String: Any],
                        let Date = sessionTime["end_time"] as? String,
                        let endDate = formatter.date(from: Date) {
                        if let oldDate = date {
                            XCTAssertLessThanOrEqual(endDate, oldDate)
                        }
                        date = endDate
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectationDesc.fulfill()
        }
        wait(for: [networkExpectation, networkExpectationDesc], timeout: 5)
    }

    func test20Find_EntryQuery_AndOrOperator() {
        let sessionType = "Breakout Session"
        let query1 = getEntryQuery().where(valueAtKey: "type", .equals(sessionType))
        let query2 = getEntryQuery().where(valueAtKey: "is_popular", .equals(false))
        
        let networkExpectation = expectation(description: "Fetch Entry where type and Popular session Test")

        self.getEntryQuery()
            .operator(.and([query1, query2]))
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 18)
                for entry in contentstackResponse.items {
                    if let type = entry.fields?["type"] as? String {
                        XCTAssertEqual(type, sessionType)
                    }
                    if let isPopular = entry.fields?["is_popular"] as? Bool {
                        XCTAssertEqual(false, isPopular)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }

        let networkExpectationOr = expectation(description: "Fetch Entry where type Or Popular session Test")

        self.getEntryQuery()
            .operator(.or([query1, query2]))
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 30)
                for entry in contentstackResponse.items {
                    if let type = entry.fields?["type"] as? String,
                        let isPopular = entry.fields?["is_popular"] as? Bool {
                        if type != sessionType && isPopular != false {
                            XCTAssertFalse(true, "Type and popular not matched")
                        }
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectationOr.fulfill()
        }
        wait(for: [networkExpectation, networkExpectationOr], timeout: 5)
    }

    func test21Find_EntryQuery_SkipLimit() {
        let networkExpectation = expectation(description: "Fetch Entry Skip Test")

        self.getEntryQuery()
            .skip(theFirst: 10)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 21)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }

        let networkExpectationOr = expectation(description: "Fetch Entry Limit Test")

        self.getEntryQuery()
            .limit(to: 10)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 10)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectationOr.fulfill()
        }
        wait(for: [networkExpectation, networkExpectationOr], timeout: 5)
    }

    func test22Find_EntryQuery_AddQuery() {
        let sessionType = "Breakout Session"
        let networkExpectation = expectation(description: "Fetch Entry Add Query Dictionary Test")

        self.getEntryQuery()
            .addQuery(dictionary: ["type": ["$ne": sessionType]])
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 13)
                for entry in contentstackResponse.items {
                    if let type = entry.fields?["type"] as? String {
                        XCTAssertNotEqual(type, sessionType)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }

        let networkExpectationKeyValue = expectation(description: "Fetch Entry Add Query Key Value Test")

        self.getEntryQuery()
            .addQuery(with: "type", value: ["$ne": sessionType])
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 13)
                for entry in contentstackResponse.items {
                    if let type = entry.fields?["type"] as? String {
                        XCTAssertNotEqual(type, sessionType)
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectationKeyValue.fulfill()
        }
        wait(for: [networkExpectation, networkExpectationKeyValue], timeout: 5)

    }

    func test23Find_EntryQuery_AddParam() {
        let networkExpectation = expectation(description: "Fetch Entry Add Parameter Dictionary Test")

        self.getEntryQuery()
            .addURIParam(dictionary: ["include_count": "true"])
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.count, 31)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }

        let networkExpectationKeyValue = expectation(description: "Fetch Entry Add Parameter Key Value Test")

        self.getEntryQuery()
            .addURIParam(with: "include_count", value: "true")
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.count, 31)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectationKeyValue.fulfill()
        }
        wait(for: [networkExpectation, networkExpectationKeyValue], timeout: 5)
    }

    func test24Find_EntryQuery_IncludeOnlyFields() {
        let networkExpectation = expectation(description: "Fetch Entry Include Only Fields Test")
        let keys = ["title", "session_id", "track"]
        self.getEntryQuery()
            .only(fields: keys)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                for entry in contentstackResponse.items {
                    if let fields = entry.fields {
                        XCTAssertEqual(fields.count, 5)
                        for item in fields {
                            if item.key == "uid" || item.key == "locale" { continue }
                            XCTAssertTrue(keys.contains(item.key))
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

    func test25Find_EntryQuery_ExcludeFields() {
        let networkExpectation = expectation(description: "Fetch Entry Exclude Fields Test")
        let keys = ["title", "session_id", "track"]

        self.getEntryQuery()
            .except(fields: keys)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                for entry in contentstackResponse.items {
                    if let fields = entry.fields {
                        XCTAssertEqual(fields.count, 18)
                        for item in fields {
                            if item.key == "title" || item.key == "locale" { continue }
                            XCTAssertFalse(keys.contains(item.key))
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

    func test26Find_EntryQuery_IncludeReference() {
        let networkExpectation = expectation(description: "Fetch Entry Query Include Reference Test")

        self.getEntryQuery()
            .includeReference(with: ["track", "room"])
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                for entry in contentstackResponse.items {
                    if let fields = entry.fields {
                        if let track = fields["track"],
                            !(track is [EntryModel]) {
                            XCTFail("Reference Track is not included")
                        }
                        if let room = fields["room"],
                            !(room is [EntryModel]) {
                            XCTFail("Reference Room is not included")
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

    func test27Fetch_Entry_IncludeReference() {
        let networkExpectation = expectation(description: "Fetch Entry Include Reference Test")

        self.getEntry(uid: kEntryUID)
            .includeReference(with: ["track", "room"])
            .fetch { (result: Result<EntryModel, Error>, response) in
            switch result {
            case .success(let model):
                if let fields = model.fields {
                    if let track = fields["track"],
                        !(track is [EntryModel]) {
                        XCTFail("Reference Track is not included")
                    }
                    if let room = fields["room"],
                        !(room is [EntryModel]) {
                        XCTFail("Reference Room is not included")
                    }
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)

    }
    func test28Find_EntryQuery_IncludeReferenceOnly() {
        let networkExpectation = expectation(description: "Fetch Entry Query Include Reference Only Test")
        let keys = ["track_color"]
        self.getEntryQuery()
            .includeReferenceField(with: "track", only: keys)
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                for entry in contentstackResponse.items {
                    if let fields = entry.fields {
                        if let tracks = fields["track"] as? [[String: Any]] {
                            for track in tracks {
                                for item in track {
                                    if item.key == "uid" || item.key == "_content_type_uid" { continue }
                                    XCTAssertTrue(keys.contains(item.key))
                                }
                            }
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

    func test29Fetch_Entry_IncludeReferenceOnly() {
        let networkExpectation = expectation(description: "Fetch Entry Include Reference Only Test")
        let keys = ["track_color"]

        self.getEntry(uid: kEntryUID)
            .includeReferenceField(with: "track", only: keys)
            .fetch { (result: Result<EntryModel, Error>, response) in
            switch result {
            case .success(let model):
                if let fields = model.fields {
                    if let tracks = fields["track"] as? [[String: Any]] {
                        for track in tracks {
                            for item in track {
                                if item.key == "uid" || item.key == "_content_type_uid" { continue }
                                XCTAssertTrue(keys.contains(item.key))
                            }
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
    func test30Find_EntryQuery_IncludeReferenceExceot() {
        let networkExpectation = expectation(description: "Fetch Entry Query Include Reference Except Test")
        let keys = ["track_color"]

        self.getEntryQuery()
            .includeReferenceField(with: "track", except: ["track_color"])
            .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response) in
            switch result {
            case .success(let contentstackResponse):
                for entry in contentstackResponse.items {
                    if let fields = entry.fields {
                        if let tracks = fields["track"] as? [EntryModel] {
                            for track in tracks {
                                for item in track.fields! {
                                    XCTAssertFalse(keys.contains(item.key))
                                }
                            }
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

    func test31Fetch_Entry_IncludeReferenceExcept() {
        let networkExpectation = expectation(description: "Fetch Entry Include Reference Except Test")
        let keys = ["track_color"]

        self.getEntry(uid: kEntryUID)
            .includeReferenceField(with: "track", except: keys)
            .fetch { (result: Result<EntryModel, Error>, response) in
            switch result {
            case .success(let model):
                if let fields = model.fields {
                    if let tracks = fields["track"] as? [EntryModel] {
                        for track in tracks {
                            for item in track.fields! {
                                XCTAssertFalse(keys.contains(item.key))
                            }
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
}
