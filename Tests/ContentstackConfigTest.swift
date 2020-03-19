//
//  ContentstackConfig.swift
//  Contentstack iOS Tests
//
//  Created by Uttam Ukkoji on 16/03/20.
//

import XCTest
@testable import Contentstack
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

    static var allTests = [
              ("testUserAgent", testUserAgent),
              ("testXUserAgent", testXUserAgent),
              ("testTimeZone_changetoCurrent", testTimeZone_changetoCurrent)
           ]
}
