//
//  AssetQueryTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 20/03/20.
//

import XCTest
@testable import Contentstack
class QueryTest: XCTestCase {

    let testStringValue = "TESTVALUE"
    let testIntValue = 100
    let testDoubleValue = 1.9
    let testDateValue = Date()

    let refUID = "reference_uid"
    let reference = ["ref 1", "ref 2"]
    let reference2 = ["ref 3"]
    let referenceAll = ["ref 1", "ref 2", "ref 3"]

    func queryWhere(_ key: Entry.FieldKeys, operation: Query.Operation) {
        let query = makeQuerySUT().where(queryableCodingKey: key, operation)

        switch operation {
        case .equals(let value):
            if let params = query.queryParameter[key.rawValue] as? String {
                XCTAssertEqual(params, value)
                return
                }
        default:
            if let params = query.queryParameter[key.rawValue] as? [String: String],
                let queryParam = operation.query as? [String: String] {
                XCTAssertEqual(params, queryParam)
                return
            }
        }
        XCTFail("Query doesnt match")
    }

    func testCTQuery_whereCondition() {
        queryWhere(.uid, operation: .equals(testStringValue))
        queryWhere(.uid, operation: .notEquals(testStringValue))
        queryWhere(.title, operation: .includes(["one", "two"]))
        queryWhere(.title, operation: .excludes(["three", "four"]))
        queryWhere(.createdAt, operation: .isLessThan(testDateValue))
        queryWhere(.createdAt, operation: .isLessThanOrEqual(testStringValue))
        queryWhere(.updatedAt, operation: .isGreaterThan(testIntValue))
        queryWhere(.updatedAt, operation: .isGreaterThanOrEqual(testDoubleValue))
        queryWhere(.title, operation: .exists(true))
        queryWhere(.title, operation: .matches("^[a-z]"))
    }

    func testCTQuery_SkipLimit() {
        let value = 10
        let limitQuery = makeQuerySUT()
        limitQuery.limit(to: UInt(value))
        XCTAssertEqual(limitQuery.parameters[QueryParameter.limit], value.stringValue)

        let skipQuery = makeQuerySUT()
        skipQuery.skip(theFirst: UInt(value))
        XCTAssertEqual(skipQuery.parameters[QueryParameter.skip], value.stringValue)
    }

    func testCTQuery_Order() {
        let key = "keyPath"
        let ascQuery = makeQuerySUT()
        ascQuery.orderByAscending(keyPath: key)
        XCTAssertEqual(ascQuery.parameters[QueryParameter.asc], key)
        let descQuery = makeQuerySUT()
        descQuery.orderByDecending(keyPath: key)
        XCTAssertEqual(descQuery.parameters[QueryParameter.desc], key)
    }

    func testCTQuery_addURIParam() {
        let dictionary = ["key1": "value1",
                          "ket2": "value2"]
        let addParamQuery = makeQuerySUT().addURIParam(dictionary: dictionary)
        for (key, value) in dictionary {
            XCTAssertEqual(addParamQuery.parameters[key], value)
        }

        let key = "keyPath"
        let value = "value"
        let addParamQueryKeyVal = makeQuerySUT().addURIParam(with: key, value: value)
        XCTAssertEqual(addParamQueryKeyVal.parameters[key], value)
    }

    func testCTQuery_addQueryParam() {
        let dictionary = ["key1": "value1",
                          "ket2": "value2"]
        let addParamQuery = makeQuerySUT().addQuery(dictionary: dictionary)
        for (key, value) in dictionary {
            XCTAssertEqual(addParamQuery.queryParameter[key] as? String, value)
        }

        let key = "keyPath"
        let value = "value"
        let addParamQueryKeyVal = makeQuerySUT().addQuery(with: key, value: value)
        XCTAssertEqual(addParamQueryKeyVal.queryParameter[key] as? String, value)
    }

    func testCTQuery_Include() {
        let countQuery = makeQuerySUT().include(params: [.count])
        XCTAssertEqual(countQuery.parameters[QueryParameter.includeCount], "true")
        for key in countQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.includeCount)
        }

        let totalountQuery = makeQuerySUT().include(params: [.totalCount])
        XCTAssertEqual(totalountQuery.parameters[QueryParameter.count], "true")
        for key in totalountQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.count)
        }

        let refContentTypeQuery = makeQuerySUT().include(params: [.refContentTypeUID])
        XCTAssertEqual(refContentTypeQuery.parameters[QueryParameter.includeRefContentTypeUID], "true")
        for key in refContentTypeQuery.parameters.keys {
                XCTAssertEqual(key, QueryParameter.includeRefContentTypeUID)
        }

        let contentTypeQuery = makeQuerySUT().include(params: [.contentType])
        XCTAssertEqual(contentTypeQuery.parameters[QueryParameter.includeContentType], "true")
        XCTAssertEqual(contentTypeQuery.parameters[QueryParameter.includeGloablField], "false")
        for key in contentTypeQuery.parameters.keys {
            if ![QueryParameter.includeContentType, QueryParameter.includeGloablField].contains(key) {
                XCTAssertFalse(true, "Key outof range")
            }
        }
        let globalFieldQuery = makeQuerySUT().include(params: [.globalField])
        XCTAssertEqual(globalFieldQuery.parameters[QueryParameter.includeContentType], "true")
        XCTAssertEqual(globalFieldQuery.parameters[QueryParameter.includeGloablField], "true")
        for key in globalFieldQuery.parameters.keys {
            if ![QueryParameter.includeContentType, QueryParameter.includeGloablField].contains(key) {
                XCTAssertFalse(true, "Key outof range")
            }
        }

        let allQuery = makeQuerySUT().include(params: [.all])
        XCTAssertEqual(allQuery.parameters[QueryParameter.count], "true")
        XCTAssertEqual(allQuery.parameters[QueryParameter.includeCount], "true")
        XCTAssertEqual(allQuery.parameters[QueryParameter.includeContentType], "true")
        XCTAssertEqual(allQuery.parameters[QueryParameter.includeGloablField], "true")
        XCTAssertEqual(allQuery.parameters[QueryParameter.includeRefContentTypeUID], "true")
    }

    func testQuery_ReferenceSearch() {
        let referenceUID = "reference_uid"
        let referenceQuery = makeQuerySUT().where(
            queryableCodingKey: Entry.FieldKeys.title,
            Query.Operation.equals("10"))

        let inReference = Query.Reference.include(referenceQuery)
        let inQuery = makeQuerySUT().where(referenceAtKeyPath: referenceUID, inReference)
        if let inQueryParam = inQuery.queryParameter[referenceUID] as? String,
            let inReferenceQueryParam = inReference.query {
            XCTAssertEqual(inQueryParam, inReferenceQueryParam)
        }

        let ninReference = Query.Reference.notInclude(referenceQuery)
        let ninQuery = makeQuerySUT().where(referenceAtKeyPath: referenceUID, ninReference)
        if let inQueryParam = ninQuery.queryParameter[referenceUID] as? String,
            let inReferenceQueryParam = ninReference.query {
            XCTAssertEqual(inQueryParam, inReferenceQueryParam)
        }
    }

    func testQuery_OnlyAndExcept() {
        let fields = ["Title", "uid", "created_at"]
        let onlyQuery = makeQuerySUT().only(fields: fields)
        if let param = onlyQuery.queryParameter[QueryParameter.only] as? [String: [String]],
            let array = param[QueryParameter.base] {
            XCTAssertEqual(array, fields)
        }

        let exceptQuery = makeQuerySUT().except(fields: fields)
        if let param = exceptQuery.queryParameter[QueryParameter.except] as? [String: [String]],
            let array = param[QueryParameter.base] {
            XCTAssertEqual(array, fields)
        }

        let query = makeQuerySUT().only(fields: fields).except(fields: fields)
        if let param = query.queryParameter[QueryParameter.only] as? [String: [String]],
            let array = param[QueryParameter.base] {
            XCTAssertEqual(array, fields)
        }
        if let param = query.queryParameter[QueryParameter.except] as? [String: [String]],
            let array = param[QueryParameter.base] {
            XCTAssertEqual(array, fields)
        }
    }

    func testQuery_seachTag() {
        let searchString = "test string to search"
        let searchQuery = makeQuerySUT().search(for: searchString)
        XCTAssertEqual(searchQuery.parameters[QueryParameter.typeahead], searchString)

        let tagQuery = makeQuerySUT().tags(for: searchString)
        XCTAssertEqual(tagQuery.parameters[QueryParameter.tags], searchString)
    }

    func testQuery_OrderBy() {
        let orderKey = Entry.FieldKeys.title
        let ascQuery = makeQuerySUT().orderByAscending(propertyName: orderKey)
        XCTAssertEqual(ascQuery.parameters[QueryParameter.asc], orderKey.stringValue)

        let descQuery = makeQuerySUT().orderByDecending(propertyName: orderKey)
        XCTAssertEqual(descQuery.parameters[QueryParameter.desc], orderKey.stringValue)
    }

    func testQuery_IncludeReference() {
        let reference = ["ref 1", "ref 2"]
        let reference2 = ["ref 3"]
        let referenceAll = reference + reference2

        let includeRefQuery = makeQuerySUT().includeReference(with: reference)
        XCTAssertEqual(includeRefQuery.queryParameter[QueryParameter.include] as? [String], reference)

        _ = includeRefQuery.includeReference(with: reference2)
        XCTAssertEqual(includeRefQuery.queryParameter[QueryParameter.include] as? [String], referenceAll)
    }

    func testQuery_includeReferenceFieldOnly() {
        let onlyRefQuery = makeQuerySUT()
            .includeReferenceField(with: refUID, only: reference)
        if let param = onlyRefQuery.queryParameter[QueryParameter.only] as? [String: [String]],
            let array = param[refUID] {
            XCTAssertEqual(array, reference)
        }
        _ = onlyRefQuery.includeReferenceField(with: refUID, only: reference2)
        if let param = onlyRefQuery.queryParameter[QueryParameter.only] as? [String: [String]],
            let array = param[refUID] {
            XCTAssertEqual(array, referenceAll)
        }
    }

    func testQuery_includeReferenceFieldExcept() {
        let exceptRefQuery = makeQuerySUT()
            .includeReferenceField(with: refUID, except: reference)
        if let param = exceptRefQuery.queryParameter[QueryParameter.except] as? [String: [String]],
            let array = param[refUID] {
            XCTAssertEqual(array, reference)
        }
        _ = exceptRefQuery.includeReferenceField(with: refUID, except: reference2)
        if let param = exceptRefQuery.queryParameter[QueryParameter.except] as? [String: [String]],
            let array = param[refUID] {
            XCTAssertEqual(array, referenceAll)
        }
    }

    func testQuery_includeReferenceFieldBoth() {
        let refQuery = makeQuerySUT()
            .includeReferenceField(with: refUID, except: reference2)
            .includeReferenceField(with: refUID, only: reference)
        if let param = refQuery.queryParameter[QueryParameter.only] as? [String: [String]],
            let array = param[refUID] {
            XCTAssertEqual(array, reference)
        }
        if let param = refQuery.queryParameter[QueryParameter.except] as? [String: [String]],
            let array = param[refUID] {
            XCTAssertEqual(array, reference2)
        }
    }
}

func makeQuerySUT() -> Query {
    return Query(contentType: makeContentTypeSut(uid: "ContentTypeUID"))
}
