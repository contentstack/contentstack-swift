//
//  UtilsTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 17/03/20.
//

import XCTest
@testable import Contentstack
class UtilsTest: XCTestCase {
    let urlString = "https://images.contentstack.io/v3/assets/uid_136download"

    func testDictionary_QueryParams_toString() {
        let query = ["query": ["test": 1]]
        XCTAssertEqual(query.jsonString, "{\n  \"query\" : {\n    \"test\" : 1\n  }\n}")
    }

    func testStringToURL_InvalidURL_throws() {
        let invalideURL = "<invalidURL>"
        do {
            let url = try invalideURL.toURL()
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Invalid URL String: \(invalideURL)")
            }
        }
    }

    func testStringToURL_URL_ReturnURL() {
        let invalideURL2 = "invalidURL"
        do {
            let url = try invalideURL2.toURL()
            XCTAssertEqual(url.scheme, "https")
        } catch let error {
            XCTAssertNil(error)
        }
    }

    func testArray_toString() {
        let array: [Any] = ["First", 10, 10.1]
        XCTAssertEqual(array.jsonString!, """
        [
          "First",
          10,
          10.1
        ]
        """)
    }
    
    func testStringURL_BlankTransform_ReturnURL() {
        do {
            let url = try urlString.url(with: makeImageTransformSUT())
            XCTAssertEqual(url.absoluteString, urlString)
        } catch let error {
            XCTAssertNil(error)
        }
    }

    func testStringURL_SameTwoTransform_Throws() {
        do {
            let url = try urlString.url(with: makeImageTransformSUT().auto().auto())
            XCTAssertNil(url)
        } catch let error {
            if let imageError = error as? ImageTransformError {
                XCTAssertEqual(imageError.message, "Cannot specify two instances of ImageTransform of the same case."
                + "i.e. `[.format(.png), .format(.jpg)]` is invalid.")
            }
        }
    }

    func testStringURL_SameTransform_ReturnURL() {
        do {
            let url = try urlString.url(with: makeImageTransformSUT().auto())
            XCTAssertEqual(url.absoluteString, urlString + "?auto=webp")
        } catch let error {
            XCTAssertNil(error)
        }
    }

    static var allTests = [
           ("testDictionary_QueryParams_toString",
            testDictionary_QueryParams_toString),
            ("testStringToURL_InvalidURL_throws",
             testStringToURL_InvalidURL_throws),
            ("testStringToURL_URL_ReturnURL",
             testStringToURL_URL_ReturnURL),
            ("testStringURL_BlankTransform_ReturnURL",
             testStringURL_BlankTransform_ReturnURL),
             ("testStringURL_SameTwoTransform_Throws",
              testStringURL_SameTwoTransform_Throws),
             ("testStringURL_SameTransform_ReturnURL",
              testStringURL_SameTransform_ReturnURL)
       ]
}
