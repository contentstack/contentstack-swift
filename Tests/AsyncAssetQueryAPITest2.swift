//
//  AsyncAssetQueryAPITest2.swift
//  Contentstack
//
//  Created by Vikram Kalta on 07/12/2023.
//

import XCTest
@testable import Contentstack
import DVR

//var kAssetUID = ""
//var kAssetLocaliseUID = ""
//var kAssetTitle = ""
//var kFileName = ""
//let locale = "en-gb"

class AsyncAssetQueryAPITest2: XCTestCase {
    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "Asset")
    
    func getAsset(uid: String? = nil) -> Asset {
        return AsyncAssetQueryAPITest2.stack.asset(uid: uid)
    }
    
    func getAssetQuery() -> AssetQuery {
        return self.getAsset().query()
    }

    func asyncQueryWhere(_ key: AssetModel.QueryableCodingKey, operation: Query.Operation) async -> ContentstackResponse<AssetModel> {
        return try! await self.getAssetQuery().where(queryableCodingKey: key, operation)
            .locale("en-us")
            .find()
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
        let data: ContentstackResponse<AssetModel> = try! await self.getAssetQuery().locale("en-us").find()
        XCTAssertEqual(data.items.count, 8)
        if let asset = data.items.first {
            kAssetUID = asset.uid
            kAssetTitle = asset.title
            kFileName = asset.fileName
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test02Find_AssetQuery_whereUIDEquals() async {
        let networkExpectation = expectation(description: "Fetch where UID equals Assets Test")
        let data = await self.asyncQueryWhere(.uid, operation: .equals(kAssetUID))
        for asset in data.items {
            XCTAssertEqual(asset.uid, kAssetUID)
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test03Find_AssetQuery_whereTitleDNotEquals() async {
        let networkExpectation = expectation(description: "Fetch where Title equals Assets Test")
        let data = await self.asyncQueryWhere(.title, operation: .notEquals(kAssetTitle))
        for asset in data.items {
            XCTAssertNotEqual(asset.title, kAssetTitle)
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test04Find_AssetQuery_whereFileNameexists() async {
        let networkExpectation = expectation(description: "Fetch where fileName exists Assets Test")
        let data = await self.asyncQueryWhere(.fileName, operation: .exists(true))
        XCTAssertEqual(data.items.count, 8)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test05Find_AssetQuery_whereTitleMatchRegex() async {
        let networkExpectation = expectation(description: "Fetch where Title Match Regex Assets Test")
        let data = await self.asyncQueryWhere(.title, operation: .matches("im"))
        XCTAssertEqual(data.items.count, 4)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test06Fetch_Asset_fromUID() async {
        let networkExpectation = expectation(description: "Fetch Assets from UID Test")
        let data: ContentstackResponse<AssetModel> = try! await self.getAsset(uid: kAssetUID).fetch()
        XCTAssertEqual(data.items.first?.uid, kAssetUID)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test07Fetch_AssetQuery_WithDimensions() async {
        let networkExpectaton = expectation(description: "Fetch Assets with GlobalFields Test")
        let data: ContentstackResponse<AssetModel> = try! await self.getAssetQuery().include(params: .dimension).find()
        data.items.forEach { (model: AssetModel) in
            XCTAssertNotNil(model.dimension)
        }
        networkExpectaton.fulfill()
        wait(for: [networkExpectaton], timeout: 5)
    }
    
    func test08Fetch_Asset_WithGlobalFields() async {
        let networkExpectation = expectation(description: "Fetch Assets with GlobalFields Test")
        let data: ContentstackResponse<AssetModel> = try! await self.getAsset(uid: kAssetUID).includeDimension().fetch()
        XCTAssertNotNil(data.items.first?.dimension)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test09Fetch_AssetQuery_WithCount() async {
        let networkExpectation = expectation(description: "Fetch Assets with Count Test")
        let data: ContentstackResponse<AssetModel> = try! await self.getAssetQuery().locale("en-us").include(params: .count).find()
        XCTAssertEqual(data.count, 8)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test10Fetch_Asset_WithWrongUID_shouldFail() async {
        let networkExpectation = expectation(description: "Fetch Assets from wrong UID Test")
        do {
            let data: ContentstackResponse<AssetModel> = try await self.getAsset(uid: "UID").fetch()
            XCTFail("UID should not be present")
        } catch {
            if let error = error as? APIError {
                XCTAssertEqual(error.errorCode, 145)
                XCTAssertEqual(error.errorMessage, "Asset was not found.")
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test11Fetch_AssetQuery_WithoutFallback_Result() async {
        let networkExpectation = expectation(description: "Fetch Assets without Fallback Test")
        let data: ContentstackResponse<AssetModel> = try! await self.getAssetQuery().locale(locale).find()
        for model in data.items {
            if let fields = model.fields,
               let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
               let publishLocale = publishDetails["locale"] as? String {
                XCTAssertEqual(publishLocale, locale)
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test12Fetch_AssetQuery_Fallback_Result() async {
        let networkExpectation = expectation(description: "Fetch Assets without Fallback Test")
        let data: ContentstackResponse<AssetModel> = try! await self.getAssetQuery().locale(locale).include(params: .fallback).find()
        for model in data.items {
            if let fields = model.fields,
               let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
               let publishLocale = publishDetails["locale"] as? String {
                XCTAssert(["en-us", locale].contains(publishLocale), "\(publishLocale) not matching")
            }
        }
        if let model = data.items.first(where: { (model) -> Bool in
            if let fields = model.fields,
               let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
               let publishLocale = publishDetails["locale"] as? String {
                return publishLocale == "en-us"
            }
            return false
        }) {
            kAssetLocaliseUID = model.uid
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test12Fetch_Asset_UIDWithoutFallback_NoResult() async {
        let networkExpectation = expectation(description: "Fetch Asset from UID without Fallback Test")
        do {
            let data: ContentstackResponse<AssetModel> = try await self.getAsset(uid: kAssetLocaliseUID).locale("en-gb").fetch()
            XCTFail("UID should not be present")
        } catch {
            if let error = error as? APIError {
                XCTAssertEqual(error.errorCode, 145)
                XCTAssertEqual(error.errorMessage, "Asset was not found")
            }
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test13Fetch_Asset_UIDWithFallback_NoResult() async {
        let networkExpectation = expectation(description: "Fetch Asset from UID without Fallback Test")
        let data: ContentstackResponse<AssetModel> = try! await self.getAsset(uid: kAssetLocaliseUID).locale(locale).includeFallback().fetch()
        if let fields = data.fields,
           let publishDetails = fields["publish_details"] as? [AnyHashable: Any],
           let publishLocale = publishDetails["locale"] as? String {
            XCTAssert(["en-us", locale].contains(publishLocale), "\(publishLocale) not matching")
        }
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
}
