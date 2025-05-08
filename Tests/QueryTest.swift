//
//  AssetQueryTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 20/03/20.
//

import XCTest
@testable import ContentstackSwift
class QueryTest: XCTestCase {

    let testStringValue = "TESTVALUE"
    let testIntValue = 100
    let testDoubleValue = 1.9
    let testDateValue = Date()

    let refUID = "reference_uid"
    let reference = ["ref 1", "ref 2"]
    let reference2 = ["ref 3"]
    let referenceAll = ["ref 1", "ref 2", "ref 3"]

    func queryWhere(_ key: EntryModel.FieldKeys, operation: Query.Operation) {
        let query = makeQuerySUT().where(queryableCodingKey: key, operation)

        if let queryParam = query.queryParameter[key.rawValue],
            self.isEqual(operation: operation, queryParameter: queryParam) {
            return
        }
        XCTFail("Query doesnt match \(operation.string) \(operation.value)")
    }

    func testCTQuery_whereCondition() {
        let query = makeQuerySUT().where(valueAtKey: "ref.uid", .equals(refUID))
        if let params = query.queryParameter["ref.uid"] as? String {
            XCTAssertEqual(params, refUID)
//            return
        }
        queryWhere(.uid, operation: .equals(testStringValue))
        queryWhere(.uid, operation: .equals(testIntValue))
        queryWhere(.uid, operation: .equals(testDateValue))
        queryWhere(.uid, operation: .equals(testDoubleValue))
        
        queryWhere(.uid, operation: .notEquals(testStringValue))
        queryWhere(.uid, operation: .notEquals(testIntValue))
        queryWhere(.uid, operation: .notEquals(testDateValue))
        queryWhere(.uid, operation: .notEquals(testDoubleValue))
        
        queryWhere(.title, operation: .includes(["one", "two"]))
        queryWhere(.uid, operation: .includes([testIntValue]))
        queryWhere(.uid, operation: .includes([testDateValue]))
        queryWhere(.uid, operation: .includes([testDoubleValue]))

        queryWhere(.title, operation: .excludes(["three", "four"]))
        queryWhere(.uid, operation: .excludes([testIntValue]))
        queryWhere(.uid, operation: .excludes([testDateValue]))
        queryWhere(.uid, operation: .excludes([testDoubleValue]))

        queryWhere(.createdAt, operation: .isLessThan(testDateValue))
        queryWhere(.uid, operation: .isLessThan(testIntValue))
        queryWhere(.uid, operation: .isLessThan(testStringValue))
        queryWhere(.uid, operation: .isLessThan(testDoubleValue))

        queryWhere(.createdAt, operation: .isLessThanOrEqual(testStringValue))
        queryWhere(.uid, operation: .isLessThanOrEqual(testIntValue))
        queryWhere(.uid, operation: .isLessThanOrEqual(testDateValue))
        queryWhere(.uid, operation: .isLessThanOrEqual(testDoubleValue))

        queryWhere(.updatedAt, operation: .isGreaterThan(testIntValue))
        queryWhere(.uid, operation: .isGreaterThan(testStringValue))
        queryWhere(.uid, operation: .isGreaterThan(testDateValue))
        queryWhere(.uid, operation: .isGreaterThan(testDoubleValue))

        queryWhere(.updatedAt, operation: .isGreaterThanOrEqual(testDoubleValue))
        queryWhere(.uid, operation: .isGreaterThanOrEqual(testIntValue))
        queryWhere(.uid, operation: .isGreaterThanOrEqual(testDateValue))
        queryWhere(.uid, operation: .isGreaterThanOrEqual(testStringValue))

        queryWhere(.title, operation: .exists(true))
        queryWhere(.title, operation: .matches("^[a-z]"))
    }

    func testCTQuery_SkipLimit() {
        let value = 10
        let limitQuery = makeQuerySUT()
        limitQuery.limit(to: UInt(value))
        XCTAssertEqual(limitQuery.parameters.query(), "\(QueryParameter.limit)=\(value)")

        let skipQuery = makeQuerySUT()
        skipQuery.skip(theFirst: UInt(value))
        XCTAssertEqual(skipQuery.parameters.query(), "\(QueryParameter.skip)=\(value)")
    }

    func testCTQuery_Order() {
        let key = "keyPath"
        let ascQuery = makeQuerySUT()
        ascQuery.orderByAscending(keyPath: key)
        XCTAssertEqual(ascQuery.parameters.query(), "\(QueryParameter.asc)=\(key)")
        let descQuery = makeQuerySUT()
        descQuery.orderByDecending(keyPath: key)
        XCTAssertEqual(descQuery.parameters.query(), "\(QueryParameter.desc)=\(key)")
    }

    func testCTQuery_addURIParam() {
        let dictionary = ["key1": "value1",
                          "ket2": "value2"]
        let addParamQuery = makeQuerySUT().addURIParam(dictionary: dictionary)
        XCTAssertEqual(addParamQuery.parameters.query(), (dictionary as Parameters).query())

        let key = "keyPath"
        let value = "value"
        let addParamQueryKeyVal = makeQuerySUT().addURIParam(with: key, value: value)
        XCTAssertEqual(addParamQueryKeyVal.parameters.query(), "\(key)=\(value)")
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
        XCTAssertEqual(countQuery.parameters.query(), "\(QueryParameter.includeCount)=true")
        for key in countQuery.parameters.keys {
            if key != QueryParameter.contentType {
                XCTAssertEqual(key, QueryParameter.includeCount)
            }
        }

        let refContentTypeQuery = makeQuerySUT().include(params: [.refContentTypeUID])
        XCTAssertEqual(refContentTypeQuery.parameters.query(), "\(QueryParameter.includeRefContentTypeUID)=true")
        for key in refContentTypeQuery.parameters.keys {
            if key != QueryParameter.contentType {
                XCTAssertEqual(key, QueryParameter.includeRefContentTypeUID)
            }
        }

        let incContentType: Parameters = [QueryParameter.includeContentType: true,
                                      QueryParameter.includeGloablField: false]
        let contentTypeQuery = makeQuerySUT().include(params: [.contentType])
        XCTAssertEqual(contentTypeQuery.parameters.query(), incContentType.query())
        for key in contentTypeQuery.parameters.keys {
            if ![QueryParameter.includeContentType, QueryParameter.includeGloablField, QueryParameter.contentType].contains(key) {
                XCTAssertFalse(true, "Key outof range")
            }
        }
        let incglobalField: Parameters = [QueryParameter.includeContentType: true,
                                      QueryParameter.includeGloablField: true]

        let globalFieldQuery = makeQuerySUT().include(params: [.globalField])
        XCTAssertEqual(globalFieldQuery.parameters.query(), incglobalField.query())
        for key in globalFieldQuery.parameters.keys {
            if ![QueryParameter.includeContentType, QueryParameter.includeGloablField, QueryParameter.contentType].contains(key) {
                XCTAssertFalse(true, "Key outof range")
            }
        }

        let includeEmbeddedItemsParam: Parameters = [QueryParameter.includeEmbeddedItems: ["BASE"]]

        let includeEmbeddedItems = makeQuerySUT().include(params: .embeddedItems)
        XCTAssertEqual(includeEmbeddedItems.parameters.query(), includeEmbeddedItemsParam.query())

        
        let param: Parameters = [QueryParameter.includeCount: true,
                                 QueryParameter.includeContentType: true,
                                 QueryParameter.includeGloablField: true,
                                 QueryParameter.includeRefContentTypeUID: true,
                                 QueryParameter.includeFallback: true,
                                 QueryParameter.includeMetadata: true,
                                 QueryParameter.includeEmbeddedItems: ["BASE"]]
        let allQuery = makeQuerySUT().include(params: [.all])
        XCTAssertEqual(allQuery.parameters.query(), param.query())
    }

    func testQuery_ReferenceSearch() {
        let referenceUID = "reference_uid"
        let referenceQuery = makeQuerySUT().where(
            queryableCodingKey: EntryModel.FieldKeys.title,
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
        var fields = ["Title", "uid", "created_at"]
        let exceotFields = ["Title", "uid", "created_at"]

        let onlyQuery = makeQuerySUT().only(fields: fields)
        let exceptQuery = makeQuerySUT().except(fields: exceotFields)
        let query = makeQuerySUT().only(fields: fields).except(fields: exceotFields)

        fields.append(contentsOf: ["locale", "title"])

        XCTAssertEqual(onlyQuery.parameters.query(),
                       ([
                        QueryParameter.only:
                            [QueryParameter.base: fields]
                        ] as Parameters).query())

        XCTAssertEqual(exceptQuery.parameters.query(),
                       ([
                       QueryParameter.except:
                           [QueryParameter.base: exceotFields]
                       ] as Parameters).query())

        XCTAssertEqual(query.parameters.query(),
                       ([
                        QueryParameter.only:
                        [QueryParameter.base: fields],
                        QueryParameter.except:
                        [QueryParameter.base: exceotFields]] as Parameters).query())
    }

    func testQuery_seachTag() {
        let searchString = "test string to search"
        let searchQuery = makeQuerySUT().search(for: searchString)
        let tagQuery = makeQuerySUT().tags(for: searchString)

        if let search = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) {
            XCTAssertEqual(searchQuery.parameters.query(), "\(QueryParameter.typeahead)=\(search)")
            XCTAssertEqual(tagQuery.parameters.query(), "\(QueryParameter.tags)=\(search)")
        }
    }

    func testQuery_OrderBy() {
        let orderKey = EntryModel.FieldKeys.title
        let ascQuery = makeQuerySUT().orderByAscending(propertyName: orderKey)
        XCTAssertEqual(ascQuery.parameters.query(), "\(QueryParameter.asc)=\(orderKey.stringValue)")

        let descQuery = makeQuerySUT().orderByDecending(propertyName: orderKey)
        XCTAssertEqual(descQuery.parameters.query(), "\(QueryParameter.desc)=\(orderKey.stringValue)")
    }

    func testQuery_IncludeReference() {
        let reference = ["ref 1", "ref 2"]
        let reference2 = ["ref 3"]
        let referenceAll = reference + reference2

        let includeRefQuery = makeQuerySUT().includeReference(with: reference)
        XCTAssertEqual(includeRefQuery.parameters.query(),
                       ([QueryParameter.include: reference] as Parameters).query())

        _ = includeRefQuery.includeReference(with: reference2)
        XCTAssertEqual(includeRefQuery.parameters.query(),
                       ([QueryParameter.include: referenceAll] as Parameters).query())
    }

    func testQuery_includeReferenceFieldOnly() {
        let onlyRefQuery = makeQuerySUT()
            .includeReferenceField(with: refUID, only: reference)
        XCTAssertEqual(onlyRefQuery.parameters.query(),
                              ([
                                QueryParameter.include: [refUID],
                                QueryParameter.only:
                                    [refUID: reference]
                                ] as Parameters).query())

        _ = onlyRefQuery.includeReferenceField(with: refUID, only: reference2)
        XCTAssertEqual(onlyRefQuery.parameters.query(),
                              ([
                              QueryParameter.include: [refUID],
                              QueryParameter.only:
                                  [refUID: referenceAll]
                              ] as Parameters).query())
    }

    func testQuery_includeReferenceFieldExcept() {
        let exceptRefQuery = makeQuerySUT()
            .includeReferenceField(with: refUID, except: reference)
        XCTAssertEqual(exceptRefQuery.parameters.query(),
                                     ([
                                       QueryParameter.include: [refUID],
                                       QueryParameter.except:
                                           [refUID: reference]
                                       ] as Parameters).query())

        _ = exceptRefQuery.includeReferenceField(with: refUID, except: reference2)
        XCTAssertEqual(exceptRefQuery.parameters.query(),
                              ([
                              QueryParameter.include: [refUID],
                              QueryParameter.except:
                                  [refUID: referenceAll]
                              ] as Parameters).query())
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

    func testQuery_andOrOperator() {
        let query1 = makeQuerySUT().where(valueAtKeyPath: "title", Query.Operation.equals("Gold"))
        let query2 = makeQuerySUT().where(valueAtKeyPath: "name", Query.Operation.equals("John"))

        let andQuery = makeQuerySUT().operator(.and([query1, query2]))
        XCTAssertEqual(andQuery.queryParameter.jsonString!, "{\n  \"$and\" : [\n    {\n      \"title\" : \"Gold\"\n    },\n    {\n      \"name\" : \"John\"\n    }\n  ]\n}")

        let orQuery = makeQuerySUT().operator(.or([query1, query2]))
        XCTAssertEqual(orQuery.queryParameter.jsonString!, "{\n  \"$or\" : [\n    {\n      \"title\" : \"Gold\"\n    },\n    {\n      \"name\" : \"John\"\n    }\n  ]\n}")
    }
    
    func testAssetQuery_addValue() {
        let addValueQuery = makeAssetQuerySUT().addValue("value1", forHTTPHeaderField: "key1")
        XCTAssertEqual(addValueQuery.headers.keys.count, 1)
        XCTAssertEqual(addValueQuery.headers["key1"], "value1")
    }

    static var allTests = [
           ("testCTQuery_whereCondition", testCTQuery_whereCondition),
           ("testCTQuery_SkipLimit", testCTQuery_SkipLimit),
           ("testCTQuery_Order", testCTQuery_Order),
           ("testCTQuery_addURIParam", testCTQuery_addURIParam),
           ("testCTQuery_addQueryParam", testCTQuery_addQueryParam),
           ("testCTQuery_Include", testCTQuery_Include),
           ("testQuery_ReferenceSearch", testQuery_ReferenceSearch),
           ("testQuery_OnlyAndExcept", testQuery_OnlyAndExcept),
           ("testQuery_seachTag", testQuery_seachTag),
           ("testQuery_OrderBy", testQuery_OrderBy),
           ("testQuery_IncludeReference", testQuery_IncludeReference),
           ("testQuery_includeReferenceFieldOnly", testQuery_includeReferenceFieldOnly),
           ("testQuery_includeReferenceFieldExcept", testQuery_includeReferenceFieldExcept),
           ("testQuery_includeReferenceFieldBoth", testQuery_includeReferenceFieldBoth),
           ("testQuery_andOrOperator", testQuery_andOrOperator),
           ("testAssetQuery_addValue", testAssetQuery_addValue)
       ]
}

func makeQuerySUT() -> Query {
    return Query(contentType: makeContentTypeSut(uid: "ContentTypeUID"))
}
