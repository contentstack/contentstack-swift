//
//  ContentStackLogTest.swift
//  Contentstack
//
//  Created by Uttam Ukkoji on 15/04/20.
//

import XCTest
@testable import ContentstackSwift

class CustomeLogMessage: CustomLogger {
    
    var customeMessage: String?

    init() {
        
    }
    func reset() {
        customeMessage = nil
    }
    func log(message: String) {
        self.customeMessage = message
    }
}

class ContentStackLogTest: XCTestCase {

    func testContentstackPrint() {
        ContentstackLogger.logType = .print
        let message = "This message should print"
        ContentstackLogger.log(.info, message: message)
    }
    
    func testContentstackLogsLevels() {
        let customLogMessage = CustomeLogMessage()
        
        ContentstackLogger.logType = .custom(customLogMessage)
        
        // Log level is none, so nothing should be logged.
        ContentstackLogger.logLevel = .none
        var message = "This message shouldn't be returned"
        ContentstackLogger.log(.info, message: message)
        XCTAssertNil(customLogMessage.customeMessage)

        customLogMessage.reset()

        // Log level is error, so error messages should be logged, and info should not
        ContentstackLogger.logLevel = .error
        message = "This message SHOULD be logged as an error, not logged as info"
        ContentstackLogger.log(.error, message: message)
        XCTAssertEqual(customLogMessage.customeMessage, "[Contentstack] Error: " + message)
        customLogMessage.reset()
        ContentstackLogger.log(.info, message: message)
        XCTAssertNil(customLogMessage.customeMessage) // Since log level is error, logging info should not work.

        // At log level info, everything should be logged, except for none messages which are never logged.
        ContentstackLogger.logLevel = .info
        message = "This message SHOULD be logged as long as logLevel is not none."
        ContentstackLogger.log(.error, message: message)
        XCTAssertEqual(customLogMessage.customeMessage,  "[Contentstack] Error: " + message)
        customLogMessage.reset()
        XCTAssertNil(customLogMessage.customeMessage) // Sanity check on reset
        ContentstackLogger.log(.info, message: message)
        XCTAssertEqual(customLogMessage.customeMessage,  "[Contentstack] " + message)

        // Log to none, nothing should log.
        customLogMessage.reset()
        XCTAssertNil(customLogMessage.customeMessage) // Sanity check on reset
        ContentstackLogger.log(.none, message: message)
        XCTAssertNil(customLogMessage.customeMessage)

    }

}
