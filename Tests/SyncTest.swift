//
//  SyncTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 06/04/20.
//

import XCTest
@testable import Contentstack
class SyncTest: XCTestCase {
    let paginationToken = "uid_138"
    let syncToken = "uid_138"
    let lastSeqId = "uid_138"

    func testSync_Init() {
        let syncStack = makeSyncStack()
        XCTAssertEqual(syncStack.syncToken, "")
        XCTAssertEqual(syncStack.paginationToken, "")
        XCTAssertEqual(syncStack.parameter.query(), "init=true&seq_id=true")
    }

    func testSync_SyncToken() {
        let syncStack = makeSyncStack(syncToken: syncToken)
        XCTAssertEqual(syncStack.syncToken, syncToken)
        XCTAssertEqual(syncStack.paginationToken, "")
        XCTAssertEqual(syncStack.parameter.query(), "sync_token=\(syncToken)")
    }

    func testSync_PaginationToken() {
        let syncStack = makeSyncStack(paginationToken: paginationToken)
        XCTAssertEqual(syncStack.syncToken, "")
        XCTAssertEqual(syncStack.paginationToken, paginationToken)
        XCTAssertEqual(syncStack.parameter.query(), "pagination_token=\(paginationToken)")
    }
    
    func testSync_LastSeqId() {
        let syncStack = makeSyncStack(lastSeqId: lastSeqId)
        XCTAssertEqual(syncStack.syncToken, "")
        XCTAssertEqual(syncStack.lastSeqId, lastSeqId)
        XCTAssertEqual(syncStack.parameter.query(), "seq_id=\(lastSeqId)")
    }
    #if !NO_FATAL_TEST
    func testSync_BothTokens_ShouldGetFatalError() {
        expectFatalError(expectedMessage: ("Both Sync Token and Pagination Token can not be presnet.")) {
            let syncStack = makeSyncStack(syncToken: self.syncToken, paginationToken: self.paginationToken, lastSeqId: self.lastSeqId)
            XCTAssertNil(syncStack)
        }
    }
    #endif
    func testSyncableTypes_Parameter() {
        XCTAssertEqual(SyncStack.SyncableTypes.all.parameters.query(), "")
        XCTAssertEqual(SyncStack.SyncableTypes.contentType("product").parameters.query(), "content_type_uid=product")
        XCTAssertEqual(SyncStack.SyncableTypes.locale("en-gn").parameters.query(), "locale=en-gn")

        let date = Date()
        XCTAssertEqual(SyncStack.SyncableTypes.startFrom(date).parameters.query(), "start_from=\(date.stringValue)")
        XCTAssertEqual(SyncStack.SyncableTypes.publishType(.assetPublished).parameters.query(), "type=asset_published")
        XCTAssertEqual(SyncStack.SyncableTypes
            .publishType(.entryUnpublished).parameters.query(), "type=entry_unpublished")

        XCTAssertEqual(SyncStack.SyncableTypes
            .publishType(.assetUnpublished).parameters.query(), "type=asset_unpublished")

        XCTAssertEqual(SyncStack.SyncableTypes.publishType(.entryDeleted).parameters.query(), "type=entry_deleted")
        XCTAssertEqual(SyncStack.SyncableTypes.publishType(.assetDeleted).parameters.query(), "type=asset_deleted")
        XCTAssertEqual(SyncStack.SyncableTypes
            .publishType(.contentTypeDeleted).parameters.query(), "type=content_type_deleted")

    }
}

func makeSyncStack(syncToken: String = "", paginationToken: String = "", lastSeqId: String = "") -> SyncStack {
    return SyncStack(syncToken: syncToken, paginationToken: paginationToken, lastSeqId: lastSeqId)
}
