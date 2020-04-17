//
//  ContentTypeQuery.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 19/03/20.
//

import XCTest
@testable import Contentstack
class ContentTypeQueryTest: XCTestCase {
    let testStringValue = "TESTVALUE"
    let testIntValue = 100
    let testDoubleValue = 1.9
    let testDateValue = Date()

    func queryWhere(_ key: ContentTypeModel.QueryableCodingKey, operation: Query.Operation) {
        let query = makeContentTypeQuerySUT().where(queryableCodingKey: key, operation)

        if let queryParam = query.queryParameter[key.rawValue],
            self.isEqual(operation: operation, queryParameter: queryParam) {
            return
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
        let limitQuery = makeContentTypeQuerySUT()
        limitQuery.limit(to: UInt(value))
        XCTAssertEqual(limitQuery.parameters.query(), "\(QueryParameter.limit)=\(value)")

        let skipQuery = makeContentTypeQuerySUT()
        skipQuery.skip(theFirst: UInt(value))
        XCTAssertEqual(skipQuery.parameters.query(), "\(QueryParameter.skip)=\(value)")
    }

    func testCTQuery_Order() {
        let key = "keyPath"
        let ascQuery = makeContentTypeQuerySUT()
        ascQuery.orderByAscending(keyPath: key)
        XCTAssertEqual(ascQuery.parameters.query(), "\(QueryParameter.asc)=\(key)")
        let descQuery = makeContentTypeQuerySUT()
        descQuery.orderByDecending(keyPath: key)
        XCTAssertEqual(descQuery.parameters.query(), "\(QueryParameter.desc)=\(key)")
    }

    func testCTQuery_addURIParam() {
        let dictionary = ["key1": "value1",
                          "ket2": "value2"]
        let addParamQuery = makeContentTypeQuerySUT().addURIParam(dictionary: dictionary)
        XCTAssertEqual(addParamQuery.parameters.query(), (dictionary as Parameters).query())

        let key = "keyPath"
        let value = "value"
        let addParamQueryKeyVal = makeContentTypeQuerySUT().addURIParam(with: key, value: value)
        XCTAssertEqual(addParamQueryKeyVal.parameters.query(), "\(key)=\(value)")
    }

    func testCTQuery_addQueryParam() {
        let dictionary = ["key1": "value1",
                          "ket2": "value2"]
        let addParamQuery = makeContentTypeQuerySUT().addQuery(dictionary: dictionary)
        for (key, value) in dictionary {
            XCTAssertEqual(addParamQuery.queryParameter[key] as? String, value)
        }

        let key = "keyPath"
        let value = "value"
        let addParamQueryKeyVal = makeContentTypeQuerySUT().addQuery(with: key, value: value)
        XCTAssertEqual(addParamQueryKeyVal.queryParameter[key] as? String, value)
    }

    func testCTQuery_Include() {
        let countQuery = makeContentTypeQuerySUT().include(params: [.count])
        XCTAssertEqual(countQuery.parameters.query(), "\(QueryParameter.includeCount)=true")
        for key in countQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.includeCount)
        }

        let globalFieldQuery = makeContentTypeQuerySUT().include(params: [.globalFields])
        XCTAssertEqual(globalFieldQuery.parameters.query(), "\(QueryParameter.includeGloablField)=true")
        for key in globalFieldQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.includeGloablField)
        }

        let param: Parameters = [QueryParameter.includeCount: true,
                                 QueryParameter.includeGloablField: true]

        let allQuery = makeContentTypeQuerySUT().include(params: [.all])
        XCTAssertEqual(allQuery.parameters.query(), param.query())
    }

    static var allTests = [
        ("testCTQuery_whereCondition", testCTQuery_whereCondition),
        ("testCTQuery_SkipLimit", testCTQuery_SkipLimit),
        ("testCTQuery_Order", testCTQuery_Order),
        ("testCTQuery_addURIParam", testCTQuery_addURIParam),
        ("testCTQuery_addQueryParam", testCTQuery_addQueryParam),
        ("testCTQuery_Include", testCTQuery_Include)
    ]
}

func makeContentTypeQuerySUT() -> ContentTypeQuery {
    return ContentTypeQuery(stack: makeStackSut())
}
