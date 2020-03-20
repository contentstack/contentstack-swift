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

    func queryWhere(_ key: ContentType.FieldKeys, operation: Query.Operation) {
        let query = makeContentTypeQuerySUT().where(queryableCodingKey: key, operation)

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
        let limitQuery = makeContentTypeQuerySUT()
        limitQuery.limit(to: UInt(value))
        XCTAssertEqual(limitQuery.parameters[QueryParameter.limit], value.stringValue)

        let skipQuery = makeContentTypeQuerySUT()
        skipQuery.skip(theFirst: UInt(value))
        XCTAssertEqual(skipQuery.parameters[QueryParameter.skip], value.stringValue)
    }

    func testCTQuery_Order() {
        let key = "keyPath"
        let ascQuery = makeContentTypeQuerySUT()
        ascQuery.orderByAscending(keyPath: key)
        XCTAssertEqual(ascQuery.parameters[QueryParameter.asc], key)
        let descQuery = makeContentTypeQuerySUT()
        descQuery.orderByDecending(keyPath: key)
        XCTAssertEqual(descQuery.parameters[QueryParameter.desc], key)
    }

    func testCTQuery_addURIParam() {
        let dictionary = ["key1": "value1",
                          "ket2": "value2"]
        let addParamQuery = makeContentTypeQuerySUT().addURIParam(dictionary: dictionary)
        for (key, value) in dictionary {
            XCTAssertEqual(addParamQuery.parameters[key], value)
        }

        let key = "keyPath"
        let value = "value"
        let addParamQueryKeyVal = makeContentTypeQuerySUT().addURIParam(with: key, value: value)
        XCTAssertEqual(addParamQueryKeyVal.parameters[key], value)
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
        XCTAssertEqual(countQuery.parameters[QueryParameter.includeCount], "true")
        for key in countQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.includeCount)
        }

        let totalountQuery = makeContentTypeQuerySUT().include(params: [.totalCount])
        XCTAssertEqual(totalountQuery.parameters[QueryParameter.count], "true")
        for key in totalountQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.count)
        }

        let globalFieldQuery = makeContentTypeQuerySUT().include(params: [.globalFields])
        XCTAssertEqual(globalFieldQuery.parameters[QueryParameter.includeGloablField], "true")
        for key in globalFieldQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.includeGloablField)
        }

        let allQuery = makeContentTypeQuerySUT().include(params: [.all])
        XCTAssertEqual(allQuery.parameters[QueryParameter.count], "true")
        XCTAssertEqual(allQuery.parameters[QueryParameter.includeCount], "true")
        XCTAssertEqual(allQuery.parameters[QueryParameter.includeGloablField], "true")
    }
}

func makeContentTypeQuerySUT() -> ContentTypeQuery {
    return ContentTypeQuery(stack: makeStackSut())
}
