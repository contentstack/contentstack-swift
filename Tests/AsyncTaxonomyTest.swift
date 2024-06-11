//
//  AsyncTaxonomyTest.swift
//  Contentstack iOS Tests
//
//  Created by Vikram Kalta on 03/06/2024.
//

import XCTest
@testable import Contentstack
import DVR

class AsyncTaxonomyTest: XCTestCase {
    static let stack = AsyncTestContentstackClient.asyncTestStack(cassetteName: "Taxonomy")
    
    func getTaxonomy(uid: String? = nil) -> Taxonomy {
        return AsyncTaxonomyTest.stack.taxonomy()
    }
    
    func getTaxonomyQuery() -> Query {
        return self.getTaxonomy().query()
    }
    
    override class func setUp() {
        super.setUp()
        (stack.urlSession as? DVR.Session)?.beginRecording()
    }
    
    override class func tearDown() {
        super.tearDown()
        (stack.urlSession as? DVR.Session)?.endRecording()
    }
    
    func asyncQueryWhere(_ path: String, operation: Query.Operation) async -> ContentstackResponse<TaxonomyModel> {
        return try! await self.getTaxonomyQuery().where(valueAtKey: path, operation).find() as ContentstackResponse<TaxonomyModel>
    }
    
    func test01Find_TaxonomyQuery_OrOperator() async {
        let term1 = "test_term"
        let query1 = getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .equals(term1))
        let query2 = getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .equals("test_term1"))
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term or test_term1 Test")
        let data: ContentstackResponse<TaxonomyModel> = try! await self.getTaxonomyQuery().operator(.or([query1, query2])).find()
        XCTAssertEqual(data.items.count, 1)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test02Find_TaxonomyQuery_AndOperator() async {
        let term1 = "test_term"
        let query1 = getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .equals(term1))
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (and) Test")
        let data: ContentstackResponse<TaxonomyModel> = try! await self.getTaxonomyQuery().operator(.and([query1])).find()
        XCTAssertEqual(data.items.count, 1)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test03Find_TaxonomyQuery_InOperator() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (in) Test")
        let data: ContentstackResponse<TaxonomyModel> = try! await self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .includes([term1])).find()
        XCTAssertEqual(data.items.count, 1)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test04Find_TaxonomyQuery_Below() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (below) Test")
        let data: ContentstackResponse<TaxonomyModel> = try! await self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .below(term1)).find()
        XCTAssertEqual(data.items.count, 0)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test05Find_TaxonomyQuery_EqBelow() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (eq_below) Test")
        let data: ContentstackResponse<TaxonomyModel> = try! await self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .eqBelow(term1)).find()
        XCTAssertEqual(data.items.count, 1)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test06Find_TaxonomyQuery_Above() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (above) Test")
        let data: ContentstackResponse<TaxonomyModel> = try! await self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .above(term1)).find()
        XCTAssertEqual(data.items.count, 0)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
    
    func test07Find_TaxonomyQuery_EqAbove() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (eq_above) Test")
        let data: ContentstackResponse<TaxonomyModel> = try! await self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .eqAbove(term1)).find()
        XCTAssertEqual(data.items.count, 1)
        networkExpectation.fulfill()
        wait(for: [networkExpectation], timeout: 5)
    }
}
