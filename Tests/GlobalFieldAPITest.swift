//
//  GlobalFieldAPITest.swift
//  ContentstackSwift
//
//  Created by Reeshika Hosmani on 27/05/25.
//

import DVR
import XCTest

@testable import ContentstackSwift

class GlobalFieldAPITest: XCTestCase {

    static var kGlobalFieldUID: String = ""
    static let stack = TestContentstackClient.testStack(cassetteName: "GlobalField")

    func getGlobalFields() -> GlobalField {
        return GlobalFieldAPITest.stack.globalField()
    }
    func getGlobalField(uid: String? = nil) -> GlobalField {
        return GlobalFieldAPITest.stack.globalField(uid: uid)
    }

    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func test01FetchAllGlobalFields() {
        let expectation = self.expectation(description: "Fetch all global fields")
        getGlobalFields().find {
            (result: Result<ContentstackResponse<GlobalFieldModel>, Error>, responseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertNotNil(contentstackResponse)

                if let globalfield = contentstackResponse.items.first {
                    GlobalFieldAPITest.kGlobalFieldUID = globalfield.uid
                    print("✅ GlobalField UID: \(globalfield.uid)")

                } else {
                    XCTFail("❌ No global fields found in response.")
                }
            case .failure(let error):
                XCTFail("Fetch failed with error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func test02FetchSingleGlobalField() {
        let expectation = self.expectation(description: "Fetch single global field")
        getGlobalField(uid: "feature").fetch { (result: Result<GlobalFieldModel, Error>, _) in
            switch result {
            case .success(let result):
                print("✅ Global Field fetched successfully!")
                print("📌 UID: \(result.uid)")
                print("📌 Title: \(result.title)")
                print("📌 Description: \(result.description ?? "nil")")
                print("📌 Branch: \(result.branch ?? "nil")")
                // Print schema as pretty JSON
                if let schemaData = try? JSONSerialization.data(
                    withJSONObject: result.schema, options: .prettyPrinted),
                    let schemaJSON = String(data: schemaData, encoding: .utf8)
                {
                    print("📋 Schema:\n\(schemaJSON)")
                }
                XCTAssertEqual(result.uid, "feature")
            case .failure(let error):
                XCTFail("Fetch failed with error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func test03FetchGlobalFieldsWithBranch() {
        let expectation = self.expectation(description: "Fetch global fields with branch included")

        getGlobalField().includeBranch().find {
            (result: Result<ContentstackResponse<GlobalFieldModel>, Error>, responseType) in
            switch result {
            case .success(let response):
                response.items.forEach { item in
                    XCTAssertNotNil(item.branch)
                }
            case .failure(let error):
                XCTFail("Branch inclusion failed: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func test04FetchGlobalFieldWithSchema() {
        let expectation = self.expectation(description: "Fetch global field with schema")

        getGlobalField(uid: GlobalFieldAPITest.kGlobalFieldUID)
            .includeGlobalFieldSchema()
            .fetch { (result: Result<GlobalFieldModel, Error>, responseType) in
                switch result {
                case .success(let field):
                    XCTAssertNotNil(field.schema)

                case .failure(let error):
                    XCTFail("Schema inclusion failed: \(error)")
                }
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5)
    }
}
