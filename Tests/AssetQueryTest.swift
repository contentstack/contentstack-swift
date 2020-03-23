//
//  AssetQueryTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 20/03/20.
//

import XCTest
@testable import Contentstack
class AssetQueryTest: XCTestCase {

    let testStringValue = "TESTVALUE"
    let testIntValue = 100
    let testDoubleValue = 1.9
    let testDateValue = Date()

    func queryWhere(_ key: Asset.FieldKeys, operation: Query.Operation) {
        let query = makeAssetQuerySUT().where(queryableCodingKey: key, operation)

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
        let limitQuery = makeAssetQuerySUT()
        limitQuery.limit(to: UInt(value))
        XCTAssertEqual(limitQuery.parameters.query(), "\(QueryParameter.limit)=\(value)")

        let skipQuery = makeAssetQuerySUT()
        skipQuery.skip(theFirst: UInt(value))
        XCTAssertEqual(skipQuery.parameters.query(), "\(QueryParameter.skip)=\(value)")
    }

    func testCTQuery_Order() {
        let key = "keyPath"
        let ascQuery = makeAssetQuerySUT()
        ascQuery.orderByAscending(keyPath: key)
        XCTAssertEqual(ascQuery.parameters.query(), "\(QueryParameter.asc)=\(key)")
        let descQuery = makeAssetQuerySUT()
        descQuery.orderByDecending(keyPath: key)
        XCTAssertEqual(descQuery.parameters.query(), "\(QueryParameter.desc)=\(key)")
    }

    func testCTQuery_addURIParam() {
        let dictionary = ["key1": "value1",
                          "ket2": "value2"]
        let addParamQuery = makeAssetQuerySUT().addURIParam(dictionary: dictionary)
        XCTAssertEqual(addParamQuery.parameters.query(), (dictionary as Parameters).query())

        let key = "keyPath"
        let value = "value"
        let addParamQueryKeyVal = makeAssetQuerySUT().addURIParam(with: key, value: value)
        XCTAssertEqual(addParamQueryKeyVal.parameters.query(), "\(key)=\(value)")
    }

    func testCTQuery_addQueryParam() {
        let dictionary = ["key1": "value1",
                          "ket2": "value2"]
        let addParamQuery = makeAssetQuerySUT().addQuery(dictionary: dictionary)
        for (key, value) in dictionary {
            XCTAssertEqual(addParamQuery.queryParameter[key] as? String, value)
        }

        let key = "keyPath"
        let value = "value"
        let addParamQueryKeyVal = makeAssetQuerySUT().addQuery(with: key, value: value)
        XCTAssertEqual(addParamQueryKeyVal.queryParameter[key] as? String, value)
    }

    func testCTQuery_Include() {
        let countQuery = makeAssetQuerySUT().include(params: [.count])
        XCTAssertEqual(countQuery.parameters.query(), "\(QueryParameter.includeCount)=true")
        for key in countQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.includeCount)
        }

        let totalountQuery = makeAssetQuerySUT().include(params: [.totalCount])
        XCTAssertEqual(totalountQuery.parameters.query(), "\(QueryParameter.count)=true")
        for key in totalountQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.count)
        }

        let relativeURLQuery = makeAssetQuerySUT().include(params: [.relativeURL])
        XCTAssertEqual(relativeURLQuery.parameters.query(), "\(QueryParameter.relativeUrls)=true")
        for key in relativeURLQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.relativeUrls)
        }

        let dimentionQuery = makeAssetQuerySUT().include(params: [.dimention])
        XCTAssertEqual(dimentionQuery.parameters.query(), "\(QueryParameter.includeDimension)=true")
        for key in dimentionQuery.parameters.keys {
            XCTAssertEqual(key, QueryParameter.includeDimension)
        }

        let param: Parameters = [QueryParameter.count: true,
                                 QueryParameter.includeCount: true,
                                 QueryParameter.relativeUrls: true,
                                 QueryParameter.includeDimension: true]
        let allQuery = makeAssetQuerySUT().include(params: [.all])
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

func makeAssetQuerySUT() -> AssetQuery {
    return AssetQuery(stack: makeStackSut())
}
