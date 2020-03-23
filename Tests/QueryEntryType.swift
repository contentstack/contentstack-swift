//
//  QueryEntryType.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 23/03/20.
//

import XCTest
@testable import Contentstack
class Product: EntryDecodable {
    public enum FieldKeys: String, CodingKey {
           case title, uid, locale
           case createdAt = "created_at"
           case updatedAt = "updated_at"
           case createdBy = "created_by"
           case updatedBy = "updated_by"
       }
    var locale: String?
    var title: String?
    var uid: String
    var createdAt: Date?
    var updatedAt: Date?
    var createdBy: String?
    var updatedBy: String?
}

class QueryEntryType: XCTestCase {
    
    let testStringValue = "TESTVALUE"
    let testIntValue = 100
    let testDoubleValue = 1.9
    let testDateValue = Date()

    let refUID = "reference_uid"
    let reference = ["ref 1", "ref 2"]
    let reference2 = ["ref 3"]
    let referenceAll = ["ref 1", "ref 2", "ref 3"]

    func queryWhere(_ key: Product.FieldKeys, operation: Query.Operation) {
        let query = makeTypedQuerySUT().where(queryableCodingKey: key, operation)

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

    func testQuery_OrderBy() {
        let orderKey = Product.FieldKeys.title
        let ascQuery = makeTypedQuerySUT().orderByAscending(propertyName: orderKey)
        XCTAssertEqual(ascQuery.parameters.query(), "\(QueryParameter.asc)=\(orderKey.stringValue)")

        let descQuery = makeTypedQuerySUT().orderByDecending(propertyName: orderKey)
        XCTAssertEqual(descQuery.parameters.query(), "\(QueryParameter.desc)=\(orderKey.stringValue)")
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

}

func makeTypedQuerySUT() -> QueryOn<Product> {
    return QueryOn<Product>(contentType: makeContentTypeSut(uid: "contentTypeUID"))
}
