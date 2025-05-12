//
//  ContentstackConfig.swift
//  Contentstack iOS Tests
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import XCTest
@testable import ContentstackSwift
class ContentstackConfigTest: XCTestCase {

    func testUserAgent() {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let osVersionString = String(osVersion.majorVersion) + "."
            + String(osVersion.minorVersion)
            + "." + String(osVersion.patchVersion)

        let onlyVersionNumberRegexString = "\\d+\\.\\d+\\.\\d+(-(beta|RC|alpha)\\d*)?"

        let osName: String = {
            #if os(iOS)
            return "iOS"
            #elseif os(OSX)
            return "macOS"
            #elseif os(tvOS)
            return "tvOS"
            #endif
        }()

        let userAgent = " sdk contentstack-swift/\(onlyVersionNumberRegexString); platform Swift/5.0; os \(osName)/\(osVersionString);"

        let regex = try? NSRegularExpression(pattern: userAgent, options: [])
        let contentstackConfig = ContentstackConfig.default
        let matches = regex?.matches(
            in: contentstackConfig.userAgentString(),
            options: [],
            range: NSRange(location: 0,
                           length: ContentstackConfig.default.userAgentString().count))
        XCTAssertEqual(matches?.count, 1)

        let stack = makeStackSut(config: contentstackConfig)

        if let userAgent = stack.urlSession.configuration.httpAdditionalHeaders?["User-Agent"] as? String {
            let matches = regex?.matches(
                in: contentstackConfig.userAgentString(),
                options: [],
                range: NSRange(location: 0,
                               length: userAgent.count))
            XCTAssertEqual(matches?.count, 1)
        } else {
            XCTFail("User agent should be set")
        }
    }

    func testXUserAgent() {
        let onlyVersionNumberRegexString = "\\d+\\.\\d+\\.\\d+(-(beta|RC|alpha)\\d*)?"

        let userAgent = "contentstack-swift/\(onlyVersionNumberRegexString)"

        let regex = try? NSRegularExpression(pattern: userAgent, options: [])
        let contentstackConfig = ContentstackConfig.default
        let matches = regex?.matches(
            in: contentstackConfig.sdkVersionString(),
            options: [],
            range: NSRange(location: 0,
                           length: ContentstackConfig.default.sdkVersionString().count))
        XCTAssertEqual(matches?.count, 1)

        let stack = makeStackSut(config: contentstackConfig)

        if let userAgent = stack.urlSession.configuration.httpAdditionalHeaders?["X-User-Agent"] as? String {
            let matches = regex?.matches(
                in: contentstackConfig.sdkVersionString(),
                options: [],
                range: NSRange(location: 0,
                               length: userAgent.count))
            XCTAssertEqual(matches?.count, 1)
        } else {
            XCTFail("User agent should be set")
        }
    }

    func testTimeZone_changetoCurrent() {
        var config = ContentstackConfig()
        let timeZone = TimeZone.current
        config.timeZone = timeZone
        let stack = makeStackSut(config: config)
        XCTAssertEqual(stack.jsonDecoder.userInfo[.timeZoneContextKey] as? TimeZone, timeZone)
    }
    func testEarlyAccessMultipleValues() {
        var config = ContentstackConfig()
        let earlyAccess : [String] = ["Taxonomy","Teams"]
        config.setEarlyAccess(earlyAccess)
        _ = makeStackSut(config: config)
        let headers = config.getHeaders()
        XCTAssertTrue(headers.keys.contains("x-header-ea"))
        XCTAssertEqual(headers["x-header-ea"], "Taxonomy,Teams")
    }
    
    func testDefaultEarlyAccessIsNil() {
        var config = ContentstackConfig()
        config.setEarlyAccess([])
        _ = makeStackSut(config: config)
        let headers = config.getHeaders()
        print("headers::",headers)
        XCTAssertFalse(headers.keys.contains("x-header-ea"), "The headers should not contain the 'x-header-ea' key when early access is not set.")
    }

    func testEarlyAccessSingleValue() {
        var config = ContentstackConfig()
        let earlyAccessFeatures = ["feature1"]
        config.setEarlyAccess(earlyAccessFeatures)
        _ = makeStackSut(config: config)
        let headers = config.getHeaders()
        XCTAssertTrue(headers.keys.contains("x-header-ea"), "The headers should contain the 'x-header-ea' key.")
        XCTAssertEqual(headers["x-header-ea"], "feature1", "The 'x-header-ea' value should match the single early access value passed.")
    }

    func testGetHeadersWithoutEarlyAccess() {
        let config = ContentstackConfig()
        let headers = config.getHeaders()
        XCTAssertFalse(headers.keys.contains("x-header-ea"))
    }
    
    func testMultipleEarlyAccessWithSpaces() {
        var config = ContentstackConfig()
        let earlyAccess: [String] = ["Feature One", "Feature Two"]
        config.setEarlyAccess(earlyAccess)
        _ = makeStackSut(config: config)
        let headers = config.getHeaders()
        XCTAssertTrue(headers.keys.contains("x-header-ea"), "The headers should contain the 'x-header-ea' key.")
        XCTAssertEqual(headers["x-header-ea"], "Feature One,Feature Two", "The 'x-header-ea' value should match the early access values with spaces.")
    }
    
    func testDefaultConfigHasNoEarlyAccessHeaders() {
        let config = ContentstackConfig()
        _ = makeStackSut(config: config)
        let headers = config.getHeaders()
        XCTAssertFalse(headers.keys.contains("x-header-ea"), "The default config should not contain the 'x-header-ea' key.")
    }

    static var allTests = [
              ("testUserAgent", testUserAgent),
              ("testXUserAgent", testXUserAgent),
              ("testTimeZone_changetoCurrent", testTimeZone_changetoCurrent),
              ("testEarlyAccessMultipleValues", testEarlyAccessMultipleValues),
              ("testDefaultEarlyAccessIsNil", testDefaultEarlyAccessIsNil),
              ("testEarlyAccessSingleValue", testEarlyAccessSingleValue),
              ("testGetHeadersWithoutEarlyAccess", testGetHeadersWithoutEarlyAccess),
              ("testMultipleEarlyAccessWithSpaces", testMultipleEarlyAccessWithSpaces),
              ("testDefaultConfigHasNoEarlyAccessHeaders", testDefaultConfigHasNoEarlyAccessHeaders),
           ]
}
