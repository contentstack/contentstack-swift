//
//  XCTestCase+Extension.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import Foundation
import XCTest
@testable import Contentstack
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
}
