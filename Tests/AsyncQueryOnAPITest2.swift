//
//  AsyncQueryOnAPITest2.swift
//  Contentstack iOS Tests
//
//  Created by Vikram Kalta on 04/01/2024.
//

import XCTest
@testable import Contentstack
import DVR

class AsyncQueryOnAPITest2: XCTestCase {
    
    static var kEntryUID = ""
    static var kEntryTitle = ""
    
    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "QueryOn")
    
    func getEntry(uid: String? = nil) -> Entry {
        return AsyncQueryOnAPITest2.stack.contentType(uid: "session").entry(uid: uid)
    }
    
    func getEntryQuery<EntryType>(_ entry: EntryType.Type) -> QueryOn<EntryType> {
        return self.getEntry().query(entry)
    }

    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func test01FindAll_Session() async {
        
    }

    func test02FindAll_SessionReference() async {
        
    }
}
