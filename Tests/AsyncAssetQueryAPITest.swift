//
//  AsyncAssetQueryAPITest.swift
//  Contentstack
//
//  Created by Jigar Kanani on 13/10/23.
//

import XCTest

@testable import Contentstack
import DVR

class AsyncAssetQueryAPITest: XCTestCase {

    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "Asset")
    
    func getAsset(uid: String? = nil) -> Asset {
        return AsyncAssetQueryAPITest.stack.asset(uid: uid)
    }
    
    func getAssetQuery() -> AssetQuery {
        return self.getAsset().query()
    }
    
    func asyncQueryWhere(_ key: AssetModel.QueryableCodingKey, operation: Query.Operation, then completion: @escaping ((Result<ContentstackResponse<AssetModel>, Error>) -> ())) async {
        await self.getAssetQuery().where(queryableCodingKey: key, operation)
            .locale("en-us")
            .asyncFind { (result: Result<ContentstackResponse<AssetModel>, Error>, responseType) in
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
        await self.getAssetQuery().locale("en-us").asyncFind { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
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
    
    func test02Find_AssetQuery_whereUIDEquals() async {
        let networkExpectation = expectation(description: "Fetch where UID equals Assets Test")
        await self.asyncQueryWhere(.uid, operation: .equals(kAssetUID)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
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
    
    func test03Find_AssetQuery_whereTitleDNotEquals() async {
        let networkExpectation = expectation(description: "Fetch where Title equals Assets Test")
        await self.asyncQueryWhere(.title, operation: .notEquals(kAssetTitle)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
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

    func test03Find_AssetQuery_whereFileNameEquals() async {
        let networkExpectation = expectation(description: "Fetch where Title equals Assets Test")
        await self.asyncQueryWhere(.fileName, operation: .notEquals(kFileName)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
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

    func test04Find_AssetQuery_whereFileNameexists() async {
        let networkExpectation = expectation(description: "Fetch where fileName exists Assets Test")
        await self.asyncQueryWhere(.fileName, operation: .exists(true)) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
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
    
    func test05Find_AssetQuery_whereTitleMatchRegex() async {
        let networkExpectation = expectation(description: "Fetch where Title Match Regex Assets Test")
        await self.asyncQueryWhere(.title, operation: .matches("im")) { (result: Result<ContentstackResponse<AssetModel>, Error>) in
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

    func test06Fetch_Asset_fromUID() async {
        let networkExpectation = expectation(description: "Fetch Assets from UID Test")
        await self.getAsset(uid: kAssetUID).asyncFetch { (result: Result<AssetModel, Error>, response: ResponseType) in
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

    func test07Fetch_AssetQuery_WithDimentsions() async {
        let networkExpectation = expectation(description: "Fetch Assets with GLobalFields Test")
        await self.getAssetQuery()
            .include(params: .dimension)
            .asyncFind { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
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
    
    func test08Fetch_Asset_WithGlobalFields() async {
        let networkExpectation = expectation(description: "Fetch Assets with GlobalFields Test")
        await self.getAsset(uid: kAssetUID)
            .includeDimension()
            .asyncFetch { (result: Result<AssetModel, Error>, response: ResponseType) in
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
    
    func test09Fetch_AssetQuery_WithCount() async {
        let networkExpectation = expectation(description: "Fetch Assets with Count Test")
        await self.getAssetQuery()
            .locale("en-us")
            .include(params: .count)
            .asyncFind { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
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

    func test11Fetch_Asset_WithWrongUID_shouldFail() async {
         let networkExpectation = expectation(description: "Fetch Assets from wrong UID Test")
        await self.getAsset(uid: "UID").asyncFetch { (result: Result<AssetModel, Error>, response: ResponseType) in
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
    
    func test12Fetch_AssetQuery_WithoutFallback_Result() async {
        let networkExpectation = expectation(description: "Fetch Assets without Fallback Test")
        await self.getAssetQuery().locale(locale)
            .asyncFind { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let response):
                    for model in response.items {
                        if let fields = model.fields,
                            let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
                            let publishLocale = publishDetails["locale"] as? String {
                            XCTAssertEqual(publishLocale, locale)
                        }
                    }
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
            }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test13Fetch_AssetQuery_Fallback_Result() async {
        let networkExpectation = expectation(description: "Fetch Assets without Fallback Test")
        await self.getAssetQuery()
            .locale(locale)
            .include(params: .fallback)
            .asyncFind { (result: Result<ContentstackResponse<AssetModel>, Error>, response: ResponseType) in
                switch result {
                case .success(let response):
                    for model in response.items {
                        if let fields = model.fields,
                            let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
                            let publishLocale = publishDetails["locale"] as? String {
                            XCTAssert(["en-us", locale].contains(publishLocale), "\(publishLocale) not matching")
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
                        kAssetLocaliseUID = model.uid
                    }
                case .failure(let error):
                    XCTFail("\(error)")
                }
                networkExpectation.fulfill()
            }
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test14Fetch_Asset_UIDWithoutFallback_NoResult() async {
        let networkExpectation = expectation(description: "Fetch Asset from UID without Fallback Test")
        await self.getAsset(uid: kAssetLocaliseUID)
            .locale("en-gb")
            .asyncFetch { (result: Result<AssetModel, Error>, response: ResponseType) in
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
    
    func test15Fetch_Asset_UIDWithFallback_NoResult() async {
        let networkExpectation = expectation(description: "Fetch Asset from UID without Fallback Test")
        await self.getAsset(uid: kAssetLocaliseUID)
            .locale(locale)
            .includeFallback()
            .asyncFetch { (result: Result<AssetModel, Error>, response: ResponseType) in
            switch result {
            case .success(let model):
                if let fields = model.fields,
                    let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
                    let publishLocale = publishDetails["locale"] as? String {
                    XCTAssert(["en-us", locale].contains(publishLocale), "\(publishLocale) not matching")
                }
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        wait(for: [networkExpectation], timeout: 5)
    }
}
