//
//  AsyncTaxonomyTest.swift
//  Contentstack iOS Tests
//
//  Created by Vikram Kalta on 03/06/2024.
//

import XCTest
@testable import ContentstackSwift
import DVR

class TaxonomyTest: XCTestCase {
    static let stack = TestContentstackClient.testStack(cassetteName: "Taxonomy")
    
    func getTaxonomy(uid: String? = nil) -> Taxonomy {
        return TaxonomyTest.stack.taxonomy()
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
    
    func queryWhere(_ path: String, operation: Query.Operation, then completion: @escaping ((Result<ContentstackResponse<TaxonomyModel>, Error>) -> ())) {
        self.getTaxonomyQuery().where(valueAtKey: path, operation)
            .find { (result: Result<ContentstackResponse<TaxonomyModel>, Error>, responseType) in completion(result)}
    }
    
    func test01Find_TaxonomyQuery_OrOperator() async {
        let term1 = "test_term"
        let query1 = getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .equals(term1))
        let query2 = getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .equals("test_term1"))
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term or test_term1 Test")
        self.getTaxonomyQuery().operator(.or([query1, query2])).find { (result: Result<ContentstackResponse<TaxonomyModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 1)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test02Find_TaxonomyQuery_AndOperator() async {
        let term1 = "test_term"
        let query1 = getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .equals(term1))
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (and) Test")

        self.getTaxonomyQuery().operator(.and([query1])).find { (result: Result<ContentstackResponse<TaxonomyModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 1)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test03Find_TaxonomyQuery_InOperator() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (in) Test")
        self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .includes([term1])).find { (result: Result<ContentstackResponse<TaxonomyModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 1)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test04Find_TaxonomyQuery_Below() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (below) Test")
        self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .below(term1)).find {(result: Result<ContentstackResponse<TaxonomyModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 0)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test05Find_TaxonomyQuery_EqBelow() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (eq_below) Test")
        self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .eqBelow(term1)).find { (result: Result<ContentstackResponse<TaxonomyModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 1)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test06Find_TaxonomyQuery_Above() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (above) Test")
        self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .above(term1)).find { (result: Result<ContentstackResponse<TaxonomyModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 0)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
    
    func test07Find_TaxonomyQuery_EqAbove() async {
        let term1 = "test_term"
        let networkExpectation = expectation(description: "Fetch Entries where test_taxonomy is test_term (eq_above) Test")
        self.getTaxonomyQuery().where(valueAtKey: "taxonomies.test_taxonomy", .eqAbove(term1)).find { (result: Result<ContentstackResponse<TaxonomyModel>, Error>, response: ResponseType) in
            switch result {
            case .success(let contentstackResponse):
                XCTAssertEqual(contentstackResponse.items.count, 1)
            case .failure(let error):
                XCTFail("\(error)")
            }
            networkExpectation.fulfill()
        }
        
        await fulfillment(of: [networkExpectation], timeout: 5)
    }
}
