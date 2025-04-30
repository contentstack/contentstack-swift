//
//  XCTestCase+Extension.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation
import XCTest
@testable import ContentstackSwift
extension XCTestCase {
    func expectFatalError(expectedMessage: String, testcase: @escaping () -> Void) {
        let expectation = self.expectation(description: "expectingFatalError")
        var assertionMessage: String?

        FatalError.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
            self.unreachable()
        }

        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)
               waitForExpectations(timeout: 2) { _ in
                XCTAssertEqual(assertionMessage, expectedMessage)
                FatalError.restoreFatalError()
        }
    }

    private func unreachable() -> Never {
        repeat {
            RunLoop.current.run()
        } while (true)
    }

    internal func isEqual<T: Equatable>(type: T.Type, _ lhs: Any, _ rhs: Any) -> Bool {
        guard let lhs = lhs as? T, let rhs = rhs as? T else { return false }
        return lhs == rhs
    }
    
    func isEqual(operation: Query.Operation, queryParameter: Any) -> Bool {
        switch operation {
        case .equals(let value):
            if let params = queryParameter as? QueryableRange {
                return params.isEquals(to: value)
            }
        case .notEquals(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$ne"],
                let queryParamIn = queryParam["$ne"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .includes(let value):
            if let params = queryParameter as? [String: [QueryableRange]],
                let queryParam = operation.query as? [String: [QueryableRange]],
                let paramsIn = params["$in"],
                let queryParamIn = queryParam["$in"] {
                return true
            }
        case .excludes(let value):
            if let params = queryParameter as? [String: [QueryableRange]],
                let queryParam = operation.query as? [String: [QueryableRange]],
                let paramsIn = params["$nin"],
                let queryParamIn = queryParam["$nin"] {
                return true
            }
        case .isLessThan(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$lt"],
                let queryParamIn = queryParam["$lt"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .isLessThanOrEqual(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$lte"],
                let queryParamIn = queryParam["$lte"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .isGreaterThan(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$gt"],
                let queryParamIn = queryParam["$gt"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .isGreaterThanOrEqual(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$gte"],
                let queryParamIn = queryParam["$gte"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .exists(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$exists"],
                let queryParamIn = queryParam["$exists"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .matches(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$regex"],
                let queryParamIn = queryParam["$regex"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .eqBelow(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$eq_below"],
                let queryParamIn = queryParam["$eq_below"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .below(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$below"],
                let queryParamIn = queryParam["$below"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .eqAbove(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$eq_above"],
                let queryParamIn = queryParam["$eq_above"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        case .above(let value):
            if let params = queryParameter as? [String: QueryableRange],
                let queryParam = operation.query as? [String: QueryableRange],
                let paramsIn = params["$above"],
                let queryParamIn = queryParam["$above"],
                paramsIn.isEquals(to: queryParamIn),
                paramsIn.isEquals(to: value) {
                return true
            }
        }
        return false
    }
}

