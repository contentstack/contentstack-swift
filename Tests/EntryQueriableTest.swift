//
//  EntryQueriable.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 26/03/20.
//

import XCTest
@testable import ContentstackSwift
class EntryQueriableTest: XCTestCase {

    let refUID = "reference_uid"
    let reference = ["ref 1", "ref 2"]
    let reference2 = ["ref 3"]
    let referenceAll = ["ref 1", "ref 2", "ref 3"]

    func testCTQuery_Include() {
        let countQuery = makeEntrySut(contentTypeuid: "content_type_uid").include(params: [.count])
        XCTAssertEqual(countQuery.parameters.query(), "\(QueryParameter.includeCount)=true")
        for key in countQuery.parameters.keys {
            if key != QueryParameter.contentType {
                XCTAssertEqual(key, QueryParameter.includeCount)
            }
        }

        let refContentTypeQuery = makeEntrySut(contentTypeuid: "content_type_uid").include(params: [.refContentTypeUID])
        XCTAssertEqual(refContentTypeQuery.parameters.query(), "\(QueryParameter.includeRefContentTypeUID)=true")
        for key in refContentTypeQuery.parameters.keys {
            if key != QueryParameter.contentType {
                XCTAssertEqual(key, QueryParameter.includeRefContentTypeUID)
            }
        }

        let incContentType: Parameters = [QueryParameter.includeContentType: true,
                                      QueryParameter.includeGloablField: false]
        let contentTypeQuery = makeEntrySut(contentTypeuid: "content_type_uid").include(params: [.contentType])
        XCTAssertEqual(contentTypeQuery.parameters.query(), incContentType.query())
        for key in contentTypeQuery.parameters.keys {
            if ![QueryParameter.includeContentType, QueryParameter.includeGloablField, QueryParameter.contentType].contains(key) {
                XCTAssertFalse(true, "Key outof range")
            }
        }
        let incglobalField: Parameters = [QueryParameter.includeContentType: true,
                                      QueryParameter.includeGloablField: true]

        let globalFieldQuery = makeEntrySut(contentTypeuid: "content_type_uid").include(params: [.globalField])
        XCTAssertEqual(globalFieldQuery.parameters.query(), incglobalField.query())
        for key in globalFieldQuery.parameters.keys {
            if ![QueryParameter.includeContentType, QueryParameter.includeGloablField, QueryParameter.contentType].contains(key) {
                XCTAssertFalse(true, "Key outof range")
            }
        }
        
        let fallbackQuery = makeEntrySut(contentTypeuid: "content_type_uid").include(params: [.fallback])
        XCTAssertEqual(fallbackQuery.parameters.query(), "\(QueryParameter.includeFallback)=true")
        for key in fallbackQuery.parameters.keys {
            if key != QueryParameter.contentType {
                XCTAssertEqual(key, QueryParameter.includeFallback)
            }
        }

        let includeEmbeddedItemsParam: Parameters = [QueryParameter.includeEmbeddedItems: ["BASE"]]

        let includeEmbeddedItems =  makeEntrySut(contentTypeuid: "content_type_uid").include(params: .embeddedItems)
        XCTAssertEqual(includeEmbeddedItems.parameters.query(), includeEmbeddedItemsParam.query())

        
        let param: Parameters = [QueryParameter.includeCount: true,
                                 QueryParameter.includeContentType: true,
                                 QueryParameter.includeGloablField: true,
                                 QueryParameter.includeRefContentTypeUID: true,
                                 QueryParameter.includeFallback: true,
                                 QueryParameter.includeMetadata: true,
                                 QueryParameter.includeEmbeddedItems: ["BASE"]]
        let allQuery =  makeEntrySut(contentTypeuid: "content_type_uid").include(params: [.all])
        XCTAssertEqual(allQuery.parameters.query(), param.query())
    }

    func testQuery_OnlyAndExcept() {
        var fields = ["Title", "uid", "created_at"]
        let exceotFields = ["Title", "uid", "created_at"]

        let onlyQuery = makeEntrySut(contentTypeuid: "content_type_uid").only(fields: fields)
        let exceptQuery = makeEntrySut(contentTypeuid: "content_type_uid").except(fields: exceotFields)
        let query = makeEntrySut(contentTypeuid: "content_type_uid").only(fields: fields).except(fields: exceotFields)

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

    func testQuery_IncludeReference() {
        let reference = ["ref 1", "ref 2"]
        let reference2 = ["ref 3"]
        let referenceAll = reference + reference2

        let includeRefQuery = makeEntrySut(contentTypeuid: "content_type_uid").includeReference(with: reference)
        XCTAssertEqual(includeRefQuery.parameters.query(),
                       ([QueryParameter.include: reference] as Parameters).query())

        _ = includeRefQuery.includeReference(with: reference2)
        XCTAssertEqual(includeRefQuery.parameters.query(),
                       ([QueryParameter.include: referenceAll] as Parameters).query())
    }

    func testQuery_includeReferenceFieldOnly() {
        let onlyRefQuery = makeEntrySut(contentTypeuid: "content_type_uid")
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
        let exceptRefQuery = makeEntrySut(contentTypeuid: "content_type_uid")
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
        let refQuery = makeEntrySut(contentTypeuid: "content_type_uid")
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
