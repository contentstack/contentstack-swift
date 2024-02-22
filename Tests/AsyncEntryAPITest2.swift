//
//  AsyncEntryAPITest2.swift
//  Contentstack iOS Tests
//
//  Created by Vikram Kalta on 02/01/2024.
//

import XCTest
@testable import Contentstack
import DVR

class AsyncEntryAPITest2: XCTestCase {
    static var kEntryUID = ""
    static var kEntryLocaliseUID = ""
    static var kEntryTitle = ""
    static let locale = "en-gb"
    
    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "Entry")
    
    func getEntry(uid: String? = nil) -> Entry {
        return AsyncEntryAPITest2.stack.contentType(uid: "session").entry(uid: uid)
    }
    
    func getEntryQuery() -> Query {
        return self.getEntry().query().locale("en-us")
    }

    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func asyncQueryWhere(_ key: EntryModel.FieldKeys, operation: Query.Operation) async -> ContentstackResponse<EntryModel> {
        return try! await self.getEntryQuery().where(queryableCodingKey: key, operation).find() as ContentstackResponse<EntryModel>
    }

    func test01FindAll_EntryQuery() async {
        let networkExpectation = expectation(description: "Fetch All Entry Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().find()
        XCTAssertEqual(data.items.count, 31)
        if let entry = data.items.first {
            AsyncEntryAPITest2.kEntryUID = entry.uid
            AsyncEntryAPITest2.kEntryTitle = entry.title
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test02Find_EntryQuery_whereUIDEquals() async {
        let networkExpectation = expectation(description: "Fetch where UID equals Entry Test")
        let data: ContentstackResponse<EntryModel> = await self.asyncQueryWhere(.uid, operation: .equals(AsyncEntryAPITest2.kEntryUID))
        for entry in data.items {
            XCTAssertEqual(entry.uid, AsyncEntryAPITest2.kEntryUID)
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }

    func test03Find_EntryQuery_whereTitleDNotEquals() async {
        let networkExpectation = expectation(description: "Fetch where Title equals Entry Test")
        let data: ContentstackResponse<EntryModel> = await self.asyncQueryWhere(.title, operation: .notEquals(AsyncEntryAPITest2.kEntryTitle))
        for entry in data.items {
            XCTAssertNotEqual(entry.title, AsyncEntryAPITest2.kEntryTitle)
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test04Find_EntryQuery_whereTitleexists() async {
        let networkExpectation = expectation(description: "Fetch where Title exists Entry Test")
        let data: ContentstackResponse<EntryModel> = await self.asyncQueryWhere(.title, operation: .exists(true))
        XCTAssertEqual(data.items.count, 31)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test05Find_EntryQuery_whereTitleMatchRegex() async {
        let networkExpectation = expectation(description: "Fetch where Title Match Regex Entry Test")
        let data: ContentstackResponse<EntryModel> = await self.asyncQueryWhere(.title, operation: .matches("Tr"))
        XCTAssertEqual(data.items.count, 2)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test06Fetch_Entry_fromUID() async {
        let networkExpectation = expectation(description: "Fetch Entry from UID Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntry(uid: AsyncEntryAPITest2.kEntryUID).fetch()
        XCTAssertEqual(data.items.first?.uid, AsyncEntryAPITest2.kEntryUID)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test07Fetch_EntryQuery_WithIncludeContentType() async {
        let networkExpectation = expectation(description: "Fetch Entry Query with include ContentType Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().include(params: .contentType).find()
        XCTAssertNotNil(data.fields?["content_type"])
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test08Fetch_Entry_WithGlobalFields() async {
        let networkExpectation = expectation(description: "Fetch Entry with GlobalFields Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntry(uid: AsyncEntryAPITest2.kEntryUID).include(params: .globalField).fetch()
        if let contentType = data.items.first?.contentType {
            contentType.schema.forEach { (schema) in
                if let dataType = schema["data_type"] as? String,
                   dataType == "global_field" {
                    XCTAssertNotNil(schema["schema"])
                }
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test09Fetch_EntryQuery_WithCount() async {
        let networkExpectation = expectation(description: "Fetch Entry with Count Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().include(params: .count).find()
        XCTAssertEqual(data.count, 31)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test10Fetch_Entry_WithIncludeContentType() async {
        let networkExpectation = expectation(description: "Fetch Entry with include ContentType Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntry(uid: AsyncEntryAPITest2.kEntryUID).include(params: .contentType).fetch()
        XCTAssertNotNil(data.items.first?.contentType)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test11Fetch_Entry_WithWrongUID_shouldFail() async {
        let networkExpectation = expectation(description: "Fetch Entry from wront UID Test")
        do {
            let data: ContentstackResponse<EntryModel> = try await self.getEntry(uid: "UID").fetch()
            XCTFail("UID should not be present")
        } catch {
            if let error = error as? APIError {
                XCTAssertEqual(error.errorCode, 141)
                XCTAssertEqual(error.errorMessage, "The requested object doesn't exist.")
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test12Fetch_EntryQuery_WithGlobalFields() async {
        let networkExpectation = expectation(description: "Fetch Entry Query with GlobalFields Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().include(params: .globalField).find()
        if let contentType = data.fields?["content_type"] as? ContentTypeModel {
            contentType.schema.forEach { (schema) in
                if let dataType = schema["data_type"] as? String,
                   dataType == "global_field" {
                    XCTAssertNotNil(schema["schema"])
                }
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test13Find_EntryQuery_whereTitleIncludes() async {
        let titleArray = ["Management Strategy and Roadmap", "The Cloud is Over The Top"]
        let networkExpectation = expectation(description: "Fetch where Title Include Entry Test")
        let data: ContentstackResponse<EntryModel> = await self.asyncQueryWhere(.title, operation: .includes(titleArray))
        XCTAssertEqual(data.items.count, 2)
        for entry in data.items {
            if !titleArray.contains(entry.title) {
                XCTFail("Entry title \(entry.title) does not match")
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test14Find_EntryQuery_whereTitleExclude() async {
        let titleArray = ["Management Strategy and Roadmap", "The Cloud is Over The Top"]
        let networkExpectation = expectation(description: "Fetch where Title Exclude Entry Test")
        let data: ContentstackResponse<EntryModel> = await self.asyncQueryWhere(.title, operation: .excludes(titleArray))
        XCTAssertEqual(data.items.count, 29)
        for entry in data.items {
            if titleArray.contains(entry.title) {
                XCTFail("Entry title \(entry.title) should not match")
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test15Find_EntryQuery_wherelessThan() async {
        let formatter = Date.iso8601Formatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let date = formatter.date(from: "2018-08-27T12:30:00.000Z")!
        let networkExpectationDate = expectation(description: "Fetch where Session Time less than Date Test")
//        let (data, _): (Result<ContentstackResponse<EntryModel>, Error>, ResponseType) = try! await self.getEntryQuery().where(valueAtKey: "session_time.start_time", .isLessThan(date)).find()
//        switch data {
//        case .success(let contentstackResponse):
//            XCTAssertEqual(contentstackResponse.items.count, 29)
//            for entry in contentstackResponse.items {
//                if let sessionTime = entry.fields?["session_time"] as? [String: Any],
//                   let Date = sessionTime["start_time"] as? String,
//                   let startDate = formatter.date(from: Date) {
//                    XCTAssertLessThan(startDate, date)
//                }
//            }
//        case .failure(let error):
//            XCTFail("\(error)")
//        }
        networkExpectationDate.fulfill()
        
        let id = 2493
        let networkExpectation = expectation(description: "Fetch where Session ID less than Number Test")
        let data1: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().where(valueAtKey: "session_id", .isLessThan(id)).find()
        XCTAssertEqual(data1.items.count, 7)
        for entry in data1.items {
            if let sessionid = entry.fields?["session_id"] as? Int {
                XCTAssertLessThan(sessionid, id)
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation, networkExpectationDate], timeout: 5)
    }
    
//    func test16Find_EntryQuery_wherelessThanEqual() async {
//        let formatter = Date.iso8601Formatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
//        let date = formatter.date(from: "2018-08-27T12:30:00.000Z")!
//        let networkExpectationDate = expectation(description: "Fetch where Session Time less than or equal Date Test")
//        let (data, _): (Result<ContentstackResponse<EntryModel>, Error>, ResponseType) = try! await self.getEntryQuery().where(valueAtKey: "session_time.start_time", .isLessThanOrEqual(date)).find()
//        switch data {
//        case .success(let contentstackResponse):
//            XCTAssertEqual(contentstackResponse.items.count, 29)
//            for entry in contentstackResponse.items {
//                if let sessionTime = entry.fields?["session_time"] as? [String: Any],
//                   let Date = sessionTime["start_time"] as? String,
//                   let startDate = formatter.date(from: Date) {
//                    XCTAssertLessThanOrEqual(startDate, date)
//                }
//            }
//        case .failure(let error):
//            XCTFail("\(error)")
//        }
//        networkExpectationDate.fulfill()
//
//        let id = 2493
//        let networkExpectation = expectation(description: "Fetch where Session ID less than Or equal Number Test")
//        let (data1, _): (Result<ContentstackResponse<EntryModel>, Error>, ResponseType) = try! await self.getEntryQuery().where(valueAtKey: "session_id", .isGreaterThanOrEqual(id)).find()
//        switch data1 {
//        case .success(let contentstackResponse):
//            XCTAssertEqual(contentstackResponse.items.count, 8)
//            for entry in contentstackResponse.items {
//                if let sessionid = entry.fields?["session_id"] as? Int {
//                    XCTAssertLessThanOrEqual(sessionid, id)
//                }
//            }
//        case .failure(let error):
//            XCTFail("\(error)")
//        }
//        networkExpectation.fulfill()
//        wait(for: [networkExpectation, networkExpectationDate], timeout: 5)
//    }
    
//    func test17Find_EntryQuery_whereGreaterThan() async {
//        let formatter = Date.iso8601Formatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
//        let date = formatter.date(from: "2018-08-27T12:30:00.000Z")!
//
//        let networkExpectationDate = expectation(description: "Fetch where Session Time Greater than Date Test")
//        let (data, _): (Result<ContentstackResponse<EntryModel>, Error>, ResponseType) = try! await self.getEntryQuery().where(valueAtKey: "session_time.start_time", .isGreaterThan(date)).find()
//        switch data {
//        case .success(let contentstackResponse):
//            XCTAssertEqual(contentstackResponse.items.count, 2)
//            for entry in contentstackResponse.items {
//                if let sessionTime = entry.fields?["session_time"] as? [String: Any],
//                   let Date = sessionTime["start_time"] as? String,
//                   let startDate = formatter.date(from: Date) {
//                    XCTAssertGreaterThan(startDate, date)
//                }
//            }
//        case .failure(let error):
//            XCTFail("\(error)")
//        }
//        networkExpectationDate.fulfill()
//
//        let id = 2493
//        let networkExpectation = expectation(description: "Fetch where Session ID Greater than Number Test")
//        let (data1, _): (Result<ContentstackResponse<EntryModel>, Error>, ResponseType) = try! await self.getEntryQuery().where(valueAtKey: "session_id", .isGreaterThan(id)).find()
//        switch data1 {
//        case .success(let contentstackResponse):
//            XCTAssertEqual(contentstackResponse.items.count, 23)
//            for entry in contentstackResponse.items {
//                if let sessionid = entry.fields?["session_id"] as? Int {
//                    XCTAssertGreaterThan(sessionid, id)
//                }
//            }
//        case .failure(let error):
//            XCTFail("\(error)")
//        }
//        networkExpectation.fulfill()
//        wait(for: [networkExpectation, networkExpectationDate], timeout: 5)
//    }
    
//    func test18Find_EntryQuery_whereGreaterThanEqual() async {
//        let formatter = Date.iso8601Formatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
//        let date = formatter.date(from: "2018-08-27T12:30:00.000Z")!
//
//        let networkExpectationDate = expectation(description: "Fetch where Session Time Greater than or Equal Date Test")
//        let (data, _): (Result<ContentstackResponse<EntryModel>, Error>, ResponseType) = try! await self.getEntryQuery().where(valueAtKey: "session_time.start_time", .isGreaterThanOrEqual(date)).addValue("val", forHTTPHeaderField: "key").find()
//        switch data {
//        case .success(let contentstackResponse):
//            XCTAssertEqual(contentstackResponse.items.count, 2)
//            for entry in contentstackResponse.items {
//                if let sessionTime = entry.fields?["session_time"] as? [String: Any],
//                   let Date = sessionTime["start_time"] as? String,
//                   let startDate = formatter.date(from: Date) {
//                    XCTAssertGreaterThanOrEqual(startDate, date)
//                }
//            }
//        case .failure(let error):
//            XCTFail("\(error)")
//        }
//        networkExpectationDate.fulfill()
//
//        let id = 2493
//        let networkExpectation = expectation(description: "Fetch where Session ID Greater than or Equal Number Test")
//        let (data1, _): (Result<ContentstackResponse<EntryModel>, Error>, ResponseType) = try! await self.getEntryQuery().where(valueAtKey: "session_id", .isGreaterThanOrEqual(id)).find()
//        switch data1 {
//        case .success(let contentstackResponse):
//            XCTAssertEqual(contentstackResponse.items.count, 24)
//            for entry in contentstackResponse.items {
//                if let sessionid = entry.fields?["session_id"] as? Int {
//                    XCTAssertGreaterThanOrEqual(sessionid, id)
//                }
//            }
//        case .failure(let error):
//            XCTFail("\(error)")
//        }
//        networkExpectation.fulfill()
//        wait(for: [networkExpectation, networkExpectationDate], timeout: 5)
//    }
    
    func test19Find_EntryQuery_OrderBySessionTime() async {
        let networkExpectation = expectation(description: "Fetch Order by Ascending Start Time Test")
        let formatter = Date.iso8601Formatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().orderByAscending(keyPath: "session_time.start_time").find()
        
        var date: Date?
        for entry in data.items {
            if let sessionTime = entry.fields?["session_time"] as? [String: Any],
               let Date = sessionTime["start_time"] as? String,
               let startDate = formatter.date(from: Date) {
                if let oldDate = date {
                    XCTAssertGreaterThanOrEqual(startDate, oldDate)
                }
                date = startDate
            }
        }
        networkExpectation.fulfill()
        
        let networkExpectationDesc = expectation(description: "Fetch Order by Ascending Start Time Test")
        let data1: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().orderByAscending(keyPath: "session_time.end_time").find()
        for entry in data1.items {
            if let sessionTime = entry.fields?["session_time"] as? [String: Any],
               let Date = sessionTime["end_time"] as? String,
               let endDate = formatter.date(from: Date) {
                if let oldDate = date {
                    XCTAssertLessThanOrEqual(endDate, oldDate)
                }
                date = endDate
            }
        }
        networkExpectationDesc.fulfill()
        wait(for: [networkExpectation, networkExpectationDesc], timeout: 5)
    }
    
    func test20Find_EntryQuery_AndOrOperator() async {
        let sessionType = "Breakout Session"
        let query1 = getEntryQuery().where(valueAtKey: "type", .equals(sessionType))
        let query2 = getEntryQuery().where(valueAtKey: "is_popular", .equals(false))
        
        let networkExpectation = expectation(description: "Fetch Entry where type and Popular session Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().operator(.and([query1, query2])).find()
        XCTAssertEqual(data.items.count, 18)
        for entry in data.items {
            if let type = entry.fields?["type"] as? String {
                XCTAssertEqual(type, sessionType)
            }
            if let isPopular = entry.fields?["is_popular"] as? Bool {
                XCTAssertEqual(false, isPopular)
            }
        }
        networkExpectation.fulfill()
        
        let networkExpectationOr = expectation(description: "Fetch Entry where type Or Popular session Test")
        
        let data1: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().operator(.or([query1, query2])).find()
        XCTAssertEqual(data1.items.count, 30)
        for entry in data1.items {
            if let type = entry.fields?["type"] as? String,
               let isPopular = entry.fields?["is_popular"] as? Bool {
                if type != sessionType && isPopular != false {
                    XCTAssertFalse(true, "Type and popular not matched")
                }
            }
        }
        networkExpectationOr.fulfill()
        wait(for: [networkExpectation, networkExpectationOr], timeout: 5)
    }
    
    func test21Find_EntryQuery_SkipLimit() async {
        let networkExpectation = expectation(description: "Fetch Entry Skip Test")
        
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().skip(theFirst: 10).find()
        XCTAssertEqual(data.items.count, 21)
        networkExpectation.fulfill()
        
        let networkExpectationOr = expectation(description: "Fetch Entry Limit Test")
        let data1: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().limit(to: 10).find()
        XCTAssertEqual(data1.items.count, 10)
        networkExpectationOr.fulfill()
        wait(for: [networkExpectation, networkExpectationOr], timeout: 5)
    }
    
    func test22Find_EntryQuery_AddQuery() async {
        let sessionType = "Breakout Session"
        let networkExpectation = expectation(description: "Fetch Entry Add Query Dictionary Test")
        
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().addQuery(dictionary: ["type": ["$ne": sessionType]]).find()
        XCTAssertEqual(data.items.count, 13)
        for entry in data.items {
            if let type = entry.fields?["type"] as? String {
                XCTAssertNotEqual(type, sessionType)
            }
        }
        networkExpectation.fulfill()
        
        let networkExpectationKeyValue = expectation(description: "Fetch Entry Add Query Key Value Test")
        
        let data1: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().addQuery(with: "type", value: ["$ne": sessionType]).find()
        XCTAssertEqual(data1.items.count, 13)
        for entry in data1.items {
            if let type = entry.fields?["type"] as? String {
                XCTAssertNotEqual(type, sessionType)
            }
        }
        networkExpectationKeyValue.fulfill()
        wait(for: [networkExpectation, networkExpectationKeyValue], timeout: 5)
    }
    
    func test23Find_EntryQuery_AddParam() async {
        let networkExpectation = expectation(description: "Fetch Entry Add Parameter Dictionary Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().addURIParam(dictionary: ["include_count": "true"]).find()
        XCTAssertEqual(data.count, 31)
        networkExpectation.fulfill()
        
        let networkExpectationKeyValue = expectation(description: "Fetch Entry Add Parameter Key Value Test")

        let data1: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().addURIParam(with: "include_count", value: "true").find()
        XCTAssertEqual(data1.count, 31)
        networkExpectationKeyValue.fulfill()
        wait(for: [networkExpectation, networkExpectationKeyValue], timeout: 5)
    }
    
    func test24Find_EntryQuery_IncludeOnlyFields() async {
        let networkExpectation = expectation(description: "Fetch Entry Include Only Fields Test")
        let keys = ["title", "session_id", "track"]
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().only(fields: keys).find()
        for entry in data.items {
            if let fields = entry.fields {
                XCTAssertEqual(fields.count, 5)
                for item in fields {
                    if item.key == "uid" || item.key == "locale" { continue }
                    XCTAssertTrue(keys.contains(item.key))
                }
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test25Find_EntryQuery_ExcludeFields() async {
        let networkExpectation = expectation(description: "Fetch Entry Exclude Fields Test")
        let keys = ["title", "session_id", "track"]
        
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().except(fields: keys).find()
        for entry in data.items {
            if let fields = entry.fields {
                for item in fields {
                    if item.key == "title" || item.key == "locale" { continue }
                    XCTAssertFalse(keys.contains(item.key))
                }
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test26Find_EntryQuery_IncludeReference() async {
        let networkExpectation = expectation(description: "Fetch Entry Query Include Reference Test")
        
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().includeReference(with: ["track", "room"]).find()
        for entry in data.items {
            if let fields = entry.fields {
                if let track = fields["track"],
                   !(track is [EntryModel]) {
                    XCTFail("Reference Track is not included")
                    break;
                }
                if let room = fields["room"],
                   !(room is [EntryModel]) {
                    XCTFail("Reference Room is not included")
                    break;
                }
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test27Fetch_Entry_IncludeReference() async {
        let networkExpectation = expectation(description: "Fetch Entry Include Reference Test")
        
        let data: ContentstackResponse<EntryModel> = try! await self.getEntry(uid: AsyncEntryAPITest2.kEntryUID).includeReference(with: ["track", "room"]).fetch()
        if let fields = data.fields {
            if let track = fields["track"],
                !(track is [EntryModel]) {
                XCTFail("Reference Track is not included")
            }
            if let room = fields["room"],
                !(room is [EntryModel]) {
                XCTFail("Reference Room is not included")
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test28Find_EntryQuery_IncludeReferenceOnly() async {
        let networkExpectation = expectation(description: "Fetch Entry Query Include Reference Only Test")
        let keys = ["track_color"]
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().includeReferenceField(with: "track", only: keys).find()
        for entry in data.items {
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
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test29Fetch_Entry_IncludeReferenceOnly() async {
        let networkExpectation = expectation(description: "Fetch Entry Include Reference Only Test")
        let keys = ["track_color"]
        
        let data: ContentstackResponse<EntryModel> = try! await self.getEntry(uid: AsyncEntryAPITest2.kEntryUID).includeReferenceField(with: "track", only: keys).fetch()
        if let fields = data.fields {
            if let tracks = fields["track"] as? [[String: Any]] {
                for track in tracks {
                    for item in track {
                        if item.key == "uid" || item.key == "_content_type_uid" { continue }
                        XCTAssertTrue(keys.contains(item.key))
                    }
                }
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test30Find_EntryQuery_IncludeReferenceExceot() async {
        let networkExpectation = expectation(description: "Fetch Entry Query Include Reference Except Test")
        let keys = ["track_color"]
        
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().includeReferenceField(with: "track", except: ["track_color"]).find()
        for entry in data.items {
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
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test31Fetch_Entry_IncludeReferenceExcept() async {
        let networkExpectation = expectation(description: "Fetch Entry Include Reference Except Test")
        let keys = ["track_color"]
        
        let data: ContentstackResponse<EntryModel> = try! await self.getEntry(uid: AsyncEntryAPITest2.kEntryUID).includeReferenceField(with: "track", except: keys).fetch()
        if let fields = data.fields {
            if let tracks = fields["track"] as? [EntryModel] {
                for track in tracks {
                    for item in track.fields! {
                        XCTAssertFalse(keys.contains(item.key))
                    }
                }
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test32Fetch_EntryQuery_WithoutFallback_Result() async {
        let networkExpectation = expectation(description: "Fetch Entrys without Fallback Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().locale(locale).find()
        for model in data.items {
            if let fields = model.fields,
            let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
            let publishLocale = publishDetails["locale"] as? String {
                XCTAssertEqual(publishLocale, locale)
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test33Fetch_EntryQuery_Fallback_Result() async {
        let networkExpectation = expectation(description: "Fetch Entrys without Fallback Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntryQuery().locale(locale).include(params: .fallback).find()
        for model in data.items {
            if let fields = model.fields,
            let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
            let publishLocale = publishDetails["locale"] as? String {
                XCTAssert(["en-us", locale].contains(publishLocale), "\(publishLocale) not matching")
            }
        }
        if let model =  data.items.first(where: { (model) -> Bool in
            if let fields = model.fields,
                let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
                let publishLocale = publishDetails["locale"] as? String {
                return publishLocale == "en-us"
            }
            return false
        }) {
            AsyncEntryAPITest2.kEntryLocaliseUID = model.uid
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test34Fetch_Entry_UIDWithoutFallback_NoResult() async {
        let networkExpectation = expectation(description: "Fetch Entry from UID without Fallback Test")
        do {
            let data: ContentstackResponse<EntryModel> = try await self.getEntry(uid: AsyncEntryAPITest2.kEntryLocaliseUID).locale("en-gb").fetch()
            XCTFail("UID should not be present")
        } catch {
            if let error = error as? APIError {
                XCTAssertEqual(error.errorCode, 141)
                XCTAssertEqual(error.errorMessage, "The requested object doesn't exist.")
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test35Fetch_Entry_UIDWithFallback_NoResult() async {
        let networkExpectation = expectation(description: "Fetch Entry from UID without Fallback Test")
        let data: ContentstackResponse<EntryModel> = try! await self.getEntry(uid: AsyncEntryAPITest2.kEntryLocaliseUID).locale(locale).include(params: .fallback).fetch()
        if let fields = data.fields, let publishLocale = fields["publish_details.locale"] as? String {
            XCTAssert(["en-us", locale].contains(publishLocale), "\(publishLocale) not matching")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
}
