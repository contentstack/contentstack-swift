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

/// Regression coverage for DX-10148.
///
/// The `.nsLog` log type was previously untested and every existing test message was a plain
/// literal. That combination hid a crash: the message was handed to `NSLog` as the *format
/// string*, so percent-encoded URLs and server-supplied error text were parsed for conversion
/// specifiers and read arguments that were never supplied.
class ContentstackLoggerFormatStringTest: XCTestCase {

    private var originalLogType: ContentstackLogger.LogType!
    private var originalLogLevel: ContentstackLogger.LogLevel!

    override func setUp() {
        super.setUp()
        // These are process-global, and the rest of the suite mutates them without restoring.
        originalLogType = ContentstackLogger.logType
        originalLogLevel = ContentstackLogger.logLevel
    }

    override func tearDown() {
        ContentstackLogger.logType = originalLogType
        ContentstackLogger.logLevel = originalLogLevel
        super.tearDown()
    }

    // MARK: - Helpers

    /// A URL as `Stack.url(endpoint:parameters:)` percent-encodes it. `.urlQueryAllowed` leaves
    /// `:` alone but encodes `{`, `}` and `"`, so `{"sku":..}` becomes `%7B%22sku%22:..` — and
    /// `%22s` is a valid `char *` conversion.
    private func encodedDeliveryURL(queryJSON: String) -> String {
        let encoded = queryJSON.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            ?? queryJSON
        return "https://cdn.contentstack.io/v3/content_types/product/entries"
            + "?query=\(encoded)&environment=production"
    }

    /// Captures `stderr` while `body` runs. `NSLog` writes there as well as to the unified log,
    /// which lets us assert on what was actually emitted rather than only that we survived.
    private func captureStandardError(during body: () -> Void) -> String {
        let pipe = Pipe()
        fflush(stderr)
        let savedStderr = dup(STDERR_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

        body()

        fflush(stderr)
        dup2(savedStderr, STDERR_FILENO)
        close(savedStderr)
        try? pipe.fileHandleForWriting.close()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    // MARK: - Tests

    /// Primary regression: a percent-encoded URL must reach the log verbatim. This one fails
    /// rather than crashes on the unfixed code — a single specifier reads a zeroed argument slot,
    /// so `%22s` rendered as `(null)` and swallowed the `s` of `sku`.
    func testNSLogDoesNotInterpretPercentEncodedURLAsFormatString() throws {
        ContentstackLogger.logType = .nsLog
        ContentstackLogger.logLevel = .error

        let message = """
        Errored: 'GET' \(encodedDeliveryURL(queryJSON: "{\"sku\":\"1234567\"}"))
        Message: The request timed out.
        """

        let output = captureStandardError { ContentstackLogger.log(.error, message: message) }

        try XCTSkipIf(output.isEmpty, "NSLog did not write to stderr in this environment")

        XCTAssertTrue(output.contains("%7B%22sku%22"),
                      "The encoded query must be logged verbatim. Got: \(output)")
        XCTAssertFalse(output.contains("(null)"),
                       "A conversion specifier was consumed, so the message was still treated as "
                       + "a format string. Got: \(output)")
        XCTAssertTrue(output.contains("[Contentstack] Error: "),
                      "Existing prefix formatting must be preserved. Got: \(output)")
    }

    /// The DX-10148 crash itself. Nine or more conversions exhaust the zeroed argument-register
    /// area, so the ninth reads live stack memory and a pointer conversion there dereferences it.
    /// A realistic nine-field catalog filter is enough. On the unfixed code this killed the test
    /// process with SIGBUS/SIGSEGV rather than failing.
    func testNSLogSurvivesQueryThatExhaustsArgumentRegisters() {
        ContentstackLogger.logType = .nsLog
        ContentstackLogger.logLevel = .error

        let queryJSON = "{\"name\":\"a\",\"price\":1,\"category\":\"b\",\"description\":\"c\","
            + "\"features\":\"d\",\"size\":\"e\",\"stock\":1,\"uid\":\"f\",\"sku\":\"g\"}"
        let message = """
        Errored: 'GET' \(encodedDeliveryURL(queryJSON: queryJSON))
        Message: The request timed out.
        """

        ContentstackLogger.log(.error, message: message)
    }

    /// Server-supplied error text reaches this same logger through `APIError.handleError`, so a
    /// response body is an untrusted format string too.
    func testNSLogSurvivesHostileServerSuppliedMessage() {
        ContentstackLogger.logType = .nsLog
        ContentstackLogger.logLevel = .error

        let hostile = String(repeating: "%@ %s %n %p ", count: 8)
        ContentstackLogger.log(.error,
                               message: "Errored: 'GET' (403) https://example.com\n"
                                        + "Message: \(hostile)")
    }

    /// `.print` is the documented workaround for already-released SDK versions, so it must leave
    /// the message untouched as well.
    func testPrintLogTypeDoesNotInterpretFormatSpecifiers() {
        ContentstackLogger.logType = .print
        ContentstackLogger.logLevel = .error

        ContentstackLogger.log(.error, message: "Errored: %@ %s %7B%22sku%22 %n")
    }

    /// A custom logger must still receive the message verbatim — the existing prefix assertions
    /// depend on that, and the fix must not change what `CustomLogger` is handed.
    func testCustomLoggerReceivesMessageVerbatim() {
        let spy = CustomeLogMessage()
        ContentstackLogger.logType = .custom(spy)
        ContentstackLogger.logLevel = .error

        let message = "Errored: 'GET' "
            + encodedDeliveryURL(queryJSON: "{\"sku\":\"1\"}") + " %@ %s"
        ContentstackLogger.log(.error, message: message)

        XCTAssertEqual(spy.customeMessage, "[Contentstack] Error: " + message)
    }
}
