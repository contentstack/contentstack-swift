//
//  AssetQueryAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 15/04/20.
//

import XCTest

@testable import Contentstack
import DVR
var kAssetUID = ""
var kAssetTitle = ""
var kFileName = ""
class AssetQueryAPITest: XCTestCase {

    static let stack = TestContentstackClient.testStack(cassetteName: "Asset")
    
    func getAsset(uid: String? = nil) -> Asset {
        return AssetQueryAPITest.stack.asset(uid: uid)
    }
    
    func getAssetQuery() -> AssetQuery {
        return self.getAsset().query()
    }
    
    func queryWhere(_ key: AssetModel.QueryableCodingKey, operation: Query.Operation, then completion: @escaping ((Result<ContentstackResponse<AssetModel>, Error>) -> ())) {
        self.getAssetQuery().where(queryableCodingKey: key, operation)
            .find { (result: Result<ContentstackResponse<AssetModel>, Error>, responseType) in
                completion(result)
        }
    }
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }

    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }

    func test01FindAll_AssetQuery() {
        let networkExpectation = expectation(description: "Fetch All Assets Test")
        self.getAssetQuery().find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 8)
                if let asset = contentstackResponse.items.first {
                    kAssetUID = asset.uid
                    kAssetTitle = asset.title
                    kFileName = asset.fileName
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test02Find_AssetQuery_whereUIDEquals() {
        let networkExpectation = expectation(description: "Fetch where UID equals Assets Test")
        self.queryWhere(.uid, operation: .equals(kAssetUID)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for asset in contentstackResponse.items {
                    XCTAssertEqual(asset.uid, kAssetUID)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test03Find_AssetQuery_whereTitleDNotEquals() {
        let networkExpectation = expectation(description: "Fetch where Title equals Assets Test")
        self.queryWhere(.title, operation: .notEquals(kAssetTitle)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for asset in contentstackResponse.items {
                    XCTAssertNotEqual(asset.title, kAssetTitle)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test03Find_AssetQuery_whereFileNameEquals() {
        let networkExpectation = expectation(description: "Fetch where Title equals Assets Test")
        self.queryWhere(.fileName, operation: .notEquals(kFileName)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for asset in contentstackResponse.items {
                    XCTAssertNotEqual(asset.title, kAssetTitle)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test04Find_AssetQuery_whereFileNameexists() {
        let networkExpectation = expectation(description: "Fetch where fileName exists Assets Test")
        self.queryWhere(.fileName, operation: .exists(true)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 8)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test05Find_AssetQuery_whereTitleMatchRegex() {
        let networkExpectation = expectation(description: "Fetch where Title Match Regex Assets Test")
        self.queryWhere(.title, operation: .matches("im")) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 4)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test06Fetch_Asset_fromUID() {
        let networkExpectation = expectation(description: "Fetch Assets from UID Test")
        self.getAsset(uid: kAssetUID).fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
            switch result {
            case .success(let model):
                XCTAssertEqual(model.uid, kAssetUID)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }

    func test07Fetch_AssetQuery_WithDimentsions() {
        let networkExpectation = expectation(description: "Fetch Assets with GLobalFields Test")
        self.getAssetQuery()
            .include(params: .dimension)
            .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let contentstackResponse):
                    contentstackResponse.items.forEach { (model: AssetModel) in
                        XCTAssertNotNil(model.dimension)
                    }
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)

    }
    
    func test08Fetch_Asset_WithGlobalFields() {
        let networkExpectation = expectation(description: "Fetch Assets with GlobalFields Test")
        self.getAsset(uid: kAssetUID)
            .includeDimension()
            .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
                switch result {
                case .success(let model):
                    XCTAssertNotNil(model.dimension)
                case .failure(let error):
                    XCTFail("\(error)")
                }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test09Fetch_AssetQuery_WithCount() {
        let networkExpectation = expectation(description: "Fetch Assets with Count Test")
        self.getAssetQuery()
            .include(params: .count)
            .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let contentstackResponse):
                    XCTAssertEqual(contentstackResponse.count, 8)
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)

    }

    func test11Fetch_Asset_WithWrongUID_shouldFail() {
         let networkExpectation = expectation(description: "Fetch Assets from wrong UID Test")
        self.getAsset(uid: "UID").fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
            switch result {
            case .success:
                XCTFail("UID should not be present")
            case .failure(let error):
                if let error = error as? APIError {
                    XCTAssertEqual(error.errorCode, 145)
                    XCTAssertEqual(error.errorMessage, "Asset was not found.")
                }
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
}
