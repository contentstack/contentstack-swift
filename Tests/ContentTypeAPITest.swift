//
//  ContentTypeAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 09/04/20.
//

import XCTest
@testable import Contentstack
import DVR

class ContentTypeAPITest: XCTestCase {
    static let stack = TestContentstackClient.testStack(cassetteName: "ContentType")

    func getContentType(uid: String) -> ContentType {
        return ContentTypeQueryAPITest.stack.contentType(uid: uid)
    }
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
}
