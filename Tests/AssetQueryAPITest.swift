//
//  AssetQueryAPITest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 15/04/20.
//

import XCTest

@testable import ContentstackSwift
import DVR

class AssetQueryAPITest: XCTestCase {

    static let stack = TestContentstackClient.testStack(cassetteName: "Asset")
    static var kAssetUID = ""
    static var kAssetLocaliseUID = ""
    static var kAssetTitle = ""
    static var kFileName = ""
    static let locale = "en-gb"
    
    func getAsset(uid: String? = nil) -> Asset {
        return AssetQueryAPITest.stack.asset(uid: uid)
    }
    
    func getAssetQuery() -> AssetQuery {
        return self.getAsset().query()
    }
    
    func queryWhere(_ key: AssetModel.QueryableCodingKey, operation: Query.Operation, then completion: @escaping ((Result<ContentstackResponse<AssetModel>, Error>) -> ())) {
        self.getAssetQuery().where(queryableCodingKey: key, operation)
            .locale("en-us")
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

    func test01FindAll_AssetQuery() async {
        let networkExpectation = expectation(description: "Fetch All Assets Test")
        self.getAssetQuery().locale("en-us").find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 8)
                if let asset = contentstackResponse.items.first {
                    AssetQueryAPITest.kAssetUID = asset.uid
                    AssetQueryAPITest.kAssetTitle = asset.title
                    AssetQueryAPITest.kFileName = asset.fileName
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test02Find_AssetQuery_whereUIDEquals() async {
        let networkExpectation = expectation(description: "Fetch where UID equals Assets Test")
        self.queryWhere(.uid, operation: .equals(AssetQueryAPITest.kAssetUID)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for asset in contentstackResponse.items {
                    XCTAssertEqual(asset.uid, AssetQueryAPITest.kAssetUID)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test03Find_AssetQuery_whereTitleDNotEquals() async {
        let networkExpectation = expectation(description: "Fetch where Title equals Assets Test")
        self.queryWhere(.title, operation: .notEquals(AssetQueryAPITest.kAssetTitle)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for asset in contentstackResponse.items {
                    XCTAssertNotEqual(asset.title, AssetQueryAPITest.kAssetTitle)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }

    func test03Find_AssetQuery_whereFileNameEquals() async {
        let networkExpectation = expectation(description: "Fetch where Title equals Assets Test")
        self.queryWhere(.fileName, operation: .notEquals(AssetQueryAPITest.kFileName)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
            switch result {
            case .success(let contentstackResponse):
                for asset in contentstackResponse.items {
                    XCTAssertNotEqual(asset.title, AssetQueryAPITest.kAssetTitle)
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }

    func test04Find_AssetQuery_whereFileNameexists() async {
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
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test05Find_AssetQuery_whereTitleMatchRegex() async {
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
        await fulfillment(of: [networkExpectation], timeout: 5)
    }

    func test06Fetch_Asset_fromUID() async {
        let networkExpectation = expectation(description: "Fetch Assets from UID Test")
        self.getAsset(uid: AssetQueryAPITest.kAssetUID).fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
            switch result {
            case .success(let model):
                XCTAssertEqual(model.uid, AssetQueryAPITest.kAssetUID)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }

    func test07Fetch_AssetQuery_WithDimentsions() async {
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
        await fulfillment(of: [networkExpectation], timeout: 5)

    }
    
    func test08Fetch_Asset_WithGlobalFields() async {
        let networkExpectation = expectation(description: "Fetch Assets with GlobalFields Test")
        self.getAsset(uid: AssetQueryAPITest.kAssetUID)
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
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test09Fetch_AssetQuery_WithCount() async {
        let networkExpectation = expectation(description: "Fetch Assets with Count Test")
        self.getAssetQuery()
            .locale("en-us")
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
        await fulfillment(of: [networkExpectation], timeout: 5)

    }

    func test11Fetch_Asset_WithWrongUID_shouldFail() async {
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
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test12Fetch_AssetQuery_WithoutFallback_Result() async {
        let networkExpectation = expectation(description: "Fetch Assets without Fallback Test")
        self.getAssetQuery().locale(AssetQueryAPITest.locale)
            .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let response):
                    for model in response.items {
                        if let fields = model.fields,
                            let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
                            let publishLocale = publishDetails["locale"] as? String {
                            XCTAssertEqual(publishLocale, AssetQueryAPITest.locale)
                        }
                    }
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
            }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test13Fetch_AssetQuery_Fallback_Result() async {
        let networkExpectation = expectation(description: "Fetch Assets without Fallback Test")
        self.getAssetQuery()
            .locale(AssetQueryAPITest.locale)
            .include(params: .fallback)
            .find { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let response):
                    for model in response.items {
                        if let fields = model.fields,
                            let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
                            let publishLocale = publishDetails["locale"] as? String {
                            XCTAssert(["en-us", AssetQueryAPITest.locale].contains(publishLocale), "\(publishLocale) not matching")
                        }
                    }
                    if let model =  response.items.first(where: { (model) -> Bool in
                        if let fields = model.fields,
                            let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
                            let publishLocale = publishDetails["locale"] as? String {
                            return publishLocale == "en-us"
                        }
                        return false
                    }) {
                        AssetQueryAPITest.kAssetLocaliseUID = model.uid
                    }
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
            }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test14Fetch_Asset_UIDWithoutFallback_NoResult() async {
        let networkExpectation = expectation(description: "Fetch Asset from UID without Fallback Test")
        self.getAsset(uid: AssetQueryAPITest.kAssetLocaliseUID)
            .locale("en-gb")
            .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
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
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test15Fetch_Asset_UIDWithFallback_NoResult() async {
        let networkExpectation = expectation(description: "Fetch Asset from UID without Fallback Test")
        self.getAsset(uid: AssetQueryAPITest.kAssetLocaliseUID)
            .locale(AssetQueryAPITest.locale)
            .includeFallback()
            .fetch { (result: Result<AssetModel, Error>, response: ResponseType) in
            switch result {
            case .success(let model):
                if let fields = model.fields,
                    let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
                    let publishLocale = publishDetails["locale"] as? String {
                    XCTAssert(["en-us", AssetQueryAPITest.locale].contains(publishLocale), "\(publishLocale) not matching")
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
}
